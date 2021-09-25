/* GCompris - network-controller.h
 *
 * SPDX-FileCopyrightText: 2021 Johnny Jazeix <jazeix@gmail.com>
 *
 * Authors:
 *   Johnny Jazeix <jazeix@gmail.com>
 *
 *   SPDX-License-Identifier: GPL-3.0-or-later
 */
#ifndef NETWORKCONTROLLER_H
#define NETWORKCONTROLLER_H

class QTcpServer;
class QTcpSocket;
class QUdpSocket;

#include <QQmlEngine>
#include <QJSEngine>

namespace controllers {
    /**
     * @class NetworkController
     * @short Receive and send messages to the gcompris client instances
     *
     * Contains the tcp socket that sends and receives the different messages to
     * the clients.
     * Sends the following messages:
     * * LoginList: list of all the logins the client can choose
     * * DisplayedActivities: activities to display on the target client
     * * ActivityConfiguration: for one activity, send a specific configuration (dataset)
     *
     * Receives the following ones:
     * * Login: allows to identify a client with a name
     * * ActivityData: contains the data for one result activity send by a client
     *
     * @sa MessageHandler
     */
    class NetworkController : public QObject
    {
        Q_OBJECT

    public:
        explicit NetworkController(QObject *parent = nullptr);

        Q_INVOKABLE void broadcastDatagram();
        Q_INVOKABLE void sendLoginList();

    private slots:
        void newTcpConnection();
        void slotReadyRead();
        void disconnected();

    private:
        QTcpServer *tcpServer;
        QList<QTcpSocket*> list;
        QUdpSocket *udpSocket;

        std::map<QTcpSocket*, QByteArray> buffers;
    signals:
        void newClientReceived(QTcpSocket* socket);
        void clientDisconnected(QTcpSocket* socket);
        // void loginReceived(QTcpSocket* socket, const Login &log);
        // void activityDataReceived(QTcpSocket* socket, const ActivityRawData &data);
    };
}

#endif
