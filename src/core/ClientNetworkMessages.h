/* GCompris - ClientNetworkMessages.h
 *
 * SPDX-FileCopyrightText: 2021 Johnny Jazeix <jazeix@gmail.com>
 *
 * Authors:
 *   Johnny Jazeix <jazeix@gmail.com>
 *
 *   SPDX-License-Identifier: GPL-3.0-or-later
 */
#ifndef CLIENTNETWORKMESSAGES_H
#define CLIENTNETWORKMESSAGES_H

#include <QObject>
#include <QtQml>

class QTcpSocket;
class QUdpSocket;

class ClientNetworkMessages : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool connected MEMBER _connected NOTIFY connectionStatus)
    Q_PROPERTY(QString host READ host WRITE setHost NOTIFY hostChanged)
    Q_PROPERTY(int port READ port WRITE setPort NOTIFY portChanged)

public:
    ClientNetworkMessages();

signals:
    void newServers();
    void hostChanged();
    void portChanged();
    void connectionStatus();

    void loginListReceived(const QStringList& logins, const QStringList& passwords);
    void requestConnection(const QString& serverName);

private:
    QString _host;
    int _port;
    bool _connected;
    
public:

    bool sendMessage(const QByteArray &message);

    virtual ~ClientNetworkMessages();
    Q_INVOKABLE void connectToServer(const QString& serverName);
    Q_INVOKABLE void disconnectFromServer();

    QString host() const{
        return _host;
    }

    void setHost(const QString &newHost) {
        _host = newHost;
        emit hostChanged();
    }

    int port() const{
        return _port;
    }

    void setPort(const int &newPort) {
        _port = newPort;
        emit portChanged();
    }

private slots:
    void readFromSocket();
    void udpRead();
    void connected();
    void serverDisconnected();
    
private:
    bool sendStoredData();

    QTcpSocket *tcpSocket;
    QUdpSocket *udpSocket;
    QByteArray tcpBuffer;
};

#endif
