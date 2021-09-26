/* GCompris - ClientNetworkMessages.cpp
 *
 * SPDX-FileCopyrightText: 2021 Johnny Jazeix <jazeix@gmail.com>
 *
 * Authors:
 *   Johnny Jazeix <jazeix@gmail.com>
 *
 *   SPDX-License-Identifier: GPL-3.0-or-later
 */
#include <QString>
#include <QTcpSocket>
#include <QUdpSocket>
#include "ClientNetworkMessages.h"
#include "gcompris.pb.h"

ClientNetworkMessages::ClientNetworkMessages(): QObject(),
                                                tcpSocket(new QTcpSocket(this)),
                                                udpSocket(new QUdpSocket(this)),
                                                _connected(false)
{
    if(!udpSocket->bind(5678, QUdpSocket::ShareAddress))
         qDebug("could not bind");
     else
         qDebug("success");

    connect(udpSocket, &QUdpSocket::readyRead, this, &ClientNetworkMessages::udpRead);
    connect(tcpSocket, &QTcpSocket::connected, this, &ClientNetworkMessages::connected);
    connect(tcpSocket, &QTcpSocket::disconnected, this, &ClientNetworkMessages::serverDisconnected);
    connect(tcpSocket, &QAbstractSocket::readyRead, this, &ClientNetworkMessages::readFromSocket);
}

ClientNetworkMessages::~ClientNetworkMessages()
{
}

void ClientNetworkMessages::connectToServer(const QString& serverName)
{
    QString ip = serverName;
    int port = 5678;

    //if we are already connected to some server, disconnect from it first and then make a connection with new server
    if(_connected) { // and newServer != currentServer
        disconnectFromServer();
    }
    qDebug()<< "connect to " << ip << ":" << port;
    if(tcpSocket->state() != QAbstractSocket::ConnectedState) {
        tcpSocket->connectToHost(ip, port);
    }

    //ApplicationSettings::getInstance()->setCurrentServer(serverName);
}

void ClientNetworkMessages::disconnectFromServer()
{
    tcpSocket->disconnectFromHost();
    //ApplicationSettings::getInstance()->setCurrentServer("");
}

void ClientNetworkMessages::connected()
{
    QTcpSocket* socket = qobject_cast<QTcpSocket*>(sender());
    _connected = true;
    emit connectionStatus();
    emit hostChanged();
}

void ClientNetworkMessages::serverDisconnected() {
    _host = "";
    _connected = false;
    emit connectionStatus();
    emit hostChanged();
}

void ClientNetworkMessages::udpRead() {
    QByteArray data;
    QHostAddress address;
    quint16 port;
    data.resize(udpSocket->pendingDatagramSize());
    udpSocket->readDatagram(data.data(), data.size(), &address, &port);

    while(data.size() > 0) {
        if(data.size() < sizeof(qint32)) {
            qDebug() << "not enough data to read";
            return;
        }
        QDataStream ds(data);
        qint32 messageSize;
        ds >> messageSize; // It is already bigEndian
        qDebug() << "Message Received of size" << messageSize << "from" << address << data.size();

        data.resize(udpSocket->pendingDatagramSize());
        udpSocket->readDatagram(data.data(), data.size(), &address, &port);

        if(data.size() < messageSize) {
            qDebug() << "Message is not fully sent";
            return;
        }
        network::Container container;
        container.ParseFromArray(data.constData(), messageSize);
        qDebug() << container.type();
        switch(container.type()) {
        case network::Type::SCAN_CLIENTS:
            network::ScanClients client;
            container.data().UnpackTo(&client);
            qDebug() << "Scan deviceId" << client.deviceid().c_str() << address.toString();
            //emit newClient();
            connectToServer(address.toString());
            break;
        }
        data = data.mid(messageSize + sizeof(qint32)); // Message handled, remove it from the queue
    }
}

bool ClientNetworkMessages::sendMessage(const QByteArray &message)
{
    int size = 0;
    if(tcpSocket->state() == QAbstractSocket::ConnectedState) {
        size = tcpSocket->write(message);
    }
    return size != 0;
}

void ClientNetworkMessages::readFromSocket()
{
    QTcpSocket *clientConnection = qobject_cast<QTcpSocket *>(sender());

    tcpBuffer += clientConnection->readAll();

    while (tcpBuffer.size() > 0) {
        if (tcpBuffer.size() < sizeof(qint32)) {
            qDebug() << "not enough data to read";
            return;
        }
        QDataStream ds(tcpBuffer);
        qint32 messageSize;
        ds >> messageSize; // already bigendian
        qDebug() << "Message Received of size" << messageSize << tcpBuffer;
        if (tcpBuffer.size() < messageSize) {
            qDebug() << "Message is not fully sent";
            return;
        }
        network::Container container;
        container.ParseFromArray(tcpBuffer.constData() + sizeof(qint32), messageSize);
        qDebug() << container.type();
        switch (container.type()) {
        case network::Type::LOGIN_LIST:
            network::LoginList loginList;
            container.data().UnpackTo(&loginList);
            for (const std::string &name: loginList.login()) {
                qDebug() << "available login:" << name.c_str();
            }
            //emit newClient();
            break;
        }
        tcpBuffer = tcpBuffer.mid(messageSize + sizeof(qint32)); // Message handled, remove it from the queue
    }
    qDebug() << "All messages processed";
}
