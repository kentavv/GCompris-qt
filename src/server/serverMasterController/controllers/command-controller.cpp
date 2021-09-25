#include "command-controller.h"

#include <QList>
#include <QDebug>

using namespace framework;
using namespace models;

namespace controllers {

    class CommandController::Implementation
    {
    public:
        Implementation(CommandController *_commandController, DatabaseController *_databaseController, NavigationController *_navigationController, Client *_newClient) :
            commandController(_commandController), databaseController(_databaseController), navigationController(_navigationController), newClient(_newClient)
        {
            Command *managePupilsAddPupilToGroupsCommand = new Command(commandController, QChar(0xf0c7), tr("Add to Groups"));
            QObject::connect(managePupilsAddPupilToGroupsCommand, &Command::executed, commandController, &CommandController::onManagePupilsAddPupilToGroupsExecuted);
            managePupilsViewContextCommands.append(managePupilsAddPupilToGroupsCommand);

            Command *managePupilsRemovePupilToGroupsCommand = new Command(commandController, QChar(0xf235), tr("Remove to Groups"));
            QObject::connect(managePupilsRemovePupilToGroupsCommand, &Command::executed, commandController, &CommandController::onManagePupilsRemovePupilToGroupsExecuted);
            managePupilsViewContextCommands.append(managePupilsRemovePupilToGroupsCommand);

            Command *managePupilsAddPupilCommand = new Command(commandController, QChar(0xf234), tr("Add Pupil"));
            QObject::connect(managePupilsAddPupilCommand, &Command::executed, commandController, &CommandController::onManagePupilsAddPupilExecuted);
            managePupilsViewContextCommands.append(managePupilsAddPupilCommand);

            Command *managePupilsAddPupilFromListCommand = new Command(commandController, QChar(0xf2c2), tr("Add Pupils from List"));
            QObject::connect(managePupilsAddPupilFromListCommand, &Command::executed, commandController, &CommandController::onManagePupilsAddPupilsFromListExecuted);
            managePupilsViewContextCommands.append(managePupilsAddPupilFromListCommand);

            Command *managePupilsRemovePupilsFromListCommand = new Command(commandController, QChar(0xf503), "Remove Pupil(s)");
            QObject::connect(managePupilsRemovePupilsFromListCommand, &Command::executed, commandController, &CommandController::onManagePupilsRemovePupilsExecuted);
            managePupilsViewContextCommands.append(managePupilsRemovePupilsFromListCommand);
        }

        CommandController *commandController { nullptr };

        DatabaseController *databaseController { nullptr };
        NavigationController *navigationController { nullptr };
        Client *newClient { nullptr };
        QList<Command *> createClientViewContextCommands {};
        QList<Command *> findClientViewContextCommands {};
        QList<Command *> managePupilsViewContextCommands {};
    };

    CommandController::CommandController(QObject *parent, DatabaseController *databaseController, NavigationController *navigationController, Client *newClient) :
        QObject(parent)
    {
        implementation.reset(new Implementation(this, databaseController, navigationController, newClient));
    }

    CommandController::~CommandController()
    {
    }

    QQmlListProperty<Command> CommandController::ui_createClientViewContextCommands()
    {
#if QT_VERSION >= QT_VERSION_CHECK(5, 15, 0)
        return QQmlListProperty<Command>(this, &implementation->createClientViewContextCommands);
#else
        return QQmlListProperty<Command>(this, implementation->createClientViewContextCommands);
#endif
    }

    QQmlListProperty<Command> CommandController::ui_findClientViewContextCommands()
    {
#if QT_VERSION >= QT_VERSION_CHECK(5, 15, 0)
        return QQmlListProperty<Command>(this, &implementation->findClientViewContextCommands);
#else
        return QQmlListProperty<Command>(this, implementation->findClientViewContextCommands);
#endif
    }

    QQmlListProperty<Command> CommandController::ui_managePupilsViewContextCommands()
    {
#if QT_VERSION >= QT_VERSION_CHECK(5, 15, 0)
        return QQmlListProperty<Command>(this, &implementation->managePupilsViewContextCommands);
#else
        return QQmlListProperty<Command>(this, implementation->managePupilsViewContextCommands);
#endif
    }

    void CommandController::onManagePupilsAddPupilToGroupsExecuted()
    {
        implementation->navigationController->goAddPupilToGroupsDialog();
    }

    void CommandController::onManagePupilsRemovePupilToGroupsExecuted()
    {
        implementation->navigationController->goRemovePupilToGroupsDialog();
    }
    void CommandController::onManagePupilsAddPupilExecuted()
    {
        implementation->navigationController->goAddPupilDialog();
    }

    void CommandController::onManagePupilsAddPupilsFromListExecuted()
    {
        implementation->navigationController->goAddPupilsFromListDialog();
    }

    void CommandController::onManagePupilsRemovePupilsExecuted()
    {
        implementation->navigationController->goRemovePupilsDialog();
    }
}
