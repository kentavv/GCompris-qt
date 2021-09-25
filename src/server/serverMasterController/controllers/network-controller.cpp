/* GCompris - network-controller.cpp
 *
 * SPDX-FileCopyrightText: 2021 Johnny Jazeix <jazeix@gmail.com>
 *
 * Authors:
 *   Johnny Jazeix <jazeix@gmail.com>
 *
 *   SPDX-License-Identifier: GPL-3.0-or-later
 */
#include <QtNetwork>
#include <QtEndian>

#include "network-controller.h"
#include "gcompris.pb.h"

namespace controllers {

NetworkController::NetworkController(QObject *parent) :
    QObject(parent), tcpServer(Q_NULLPTR)
{
    udpSocket = new QUdpSocket(this);
    tcpServer = new QTcpServer(this);
    connect(tcpServer, &QTcpServer::newConnection, this, &NetworkController::newTcpConnection);

    if (!tcpServer->listen(QHostAddress::Any, 5678)) {
        qDebug() << tr("Unable to start the server: %1.").arg(tcpServer->errorString());
    }
}

void NetworkController::newTcpConnection()
{
    QTcpSocket *clientConnection = tcpServer->nextPendingConnection();

    connect(clientConnection, &QAbstractSocket::disconnected,
            this, &NetworkController::disconnected);

    connect(clientConnection, &QAbstractSocket::readyRead,
            this, &NetworkController::slotReadyRead);

    list.push_back(clientConnection);
    qDebug() << "New tcp connection" << clientConnection->peerAddress().toString();
    emit newClientReceived(clientConnection);
}

template <class T>
qint32 encodeMessage(const network::Type &messageType, T &message, std::string &encodedContainer)
{
    network::Container container;
    container.set_type(messageType);
    container.mutable_data()->PackFrom(message);
    encodedContainer = container.SerializeAsString();
    return qToBigEndian(qint32(encodedContainer.size()));
}

void NetworkController::broadcastDatagram()
{
    network::ScanClients sendClients;
    sendClients.set_deviceid(QHostInfo::localHostName().toStdString());
    std::string encodedContainer;

    qint32 encodedContainerSize = encodeMessage(network::Type::SCAN_CLIENTS, sendClients, encodedContainer);
    udpSocket->writeDatagram(reinterpret_cast<const char *>(&encodedContainerSize), sizeof(qint32), QHostAddress::Broadcast, 5678);
    qint64 data = udpSocket->writeDatagram(encodedContainer.c_str(), encodedContainer.size(), QHostAddress::Broadcast, 5678);
}

void NetworkController::slotReadyRead()
{
    QTcpSocket *clientConnection = qobject_cast<QTcpSocket *>(sender());
    QByteArray &data = buffers[clientConnection];
    data += clientConnection->readAll();

    while (data.size() > 0) {
        if (data.size() < sizeof(qint32)) {
            qDebug() << "not enough data to read";
            return;
        }
        QDataStream ds(data);
        qint32 messageSize;
        ds >> messageSize;
        messageSize = qFromBigEndian(messageSize);
        qDebug() << "Message Received of size" << messageSize << data;
        if (data.size() < messageSize) {
            qDebug() << "Message is not fully sent";
            return;
        }
        network::Container container;
        container.ParseFromArray(data.constData() + sizeof(qint32), messageSize);
        qDebug() << container.type();
        switch (container.type()) {
        case network::Type::CLIENT_ACCEPTED:
            network::ClientAccepted client;
            container.data().UnpackTo(&client);
            //emit newClient();
            break;
        }
        data = data.mid(messageSize + sizeof(qint32)); // Message handled, remove it from the queue
    }
    qDebug() << "All messages processed";
}

void NetworkController::disconnected()
{
    QTcpSocket *clientConnection = qobject_cast<QTcpSocket *>(sender());
    if (!clientConnection)
        return;
    qDebug() << "Removing " << clientConnection;
    list.removeAll(clientConnection);
    emit clientDisconnected(clientConnection);
    clientConnection->deleteLater();
}

void NetworkController::sendLoginList(/*groupName, or userList to filter from?*/)
{
    // Get all the clients
    // For each client, if it does not have a name yet, send the message
    network::LoginList loginList;
    for (std::string name: { "Bryan", "Pete" }) {
        std::string *login = loginList.add_login();
        *login = name;
    }
    std::string encodedContainer;

    qint32 encodedContainerSize = encodeMessage(network::Type::LOGIN_LIST, loginList, encodedContainer);

    for (QTcpSocket *sock: list) {
        qDebug() << "Sending " << encodedContainer.c_str() << " to " << sock;
        sock->write(reinterpret_cast<const char *>(&encodedContainerSize), sizeof(qint32));
        sock->write(encodedContainer.c_str(), encodedContainer.size());
    }
    // remove the sockets not the names
    //    QStringList usedLogins;
    //    for(const QObject* oClient: MessageHandler::getInstance()->returnClients()) {
    //        ClientData* c = (ClientData*)(oClient);
    //        if(c->getUserData()){
    //            usedLogins << c->getUserData()->getName();
    //        }
    //    }

    // AvailableLogins act;
    // for(const QObject *oC: MessageHandler::getInstance()->returnUsers()) {
    //         act._logins << ((const UserData*)oC)->getName();
    //         act._passwords << ((const UserData*)oC)->getPassword();
    // }
}
}
