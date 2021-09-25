#ifndef NAVIGATIONCONTROLLER_H
#define NAVIGATIONCONTROLLER_H

#include <QObject>

#include <models/client.h>

namespace controllers {

class NavigationController : public QObject
{
    Q_OBJECT

public:
    explicit NavigationController(QObject *parent = nullptr) :
        QObject(parent) { }

signals:
    void goManagePupilsView();
    void goCreateClientView();
    void goDashboardView();
    void goDevicesView();
    void goFindClientView();
    void goManageWorkPlanView();
    void goAddPupilsFromListDialog();
    void goRemovePupilsDialog();
    void goAddPupilDialog();
    void goAddPupilToGroupsDialog();
    void goRemovePupilToGroupsDialog();
};
}

#endif
