#ifndef CONTACT_H
#define CONTACT_H

#include <QObject>

#include <data/enumerator-decorator.h>
#include <data/string-decorator.h>
#include <data/entity.h>

namespace models {

class Contact : public data::Entity
{
    Q_OBJECT
    Q_PROPERTY(data::EnumeratorDecorator *ui_contactType MEMBER contactType CONSTANT)
    Q_PROPERTY(data::StringDecorator *ui_address MEMBER address CONSTANT)

public:
    enum eContactType {
        Unknown = 0,
        Telephone,
        Email,
        Fax
    };

public:
    explicit Contact(QObject *parent = nullptr);
    Contact(QObject *parent, const QJsonObject &json);

    data::EnumeratorDecorator *contactType { nullptr };
    data::StringDecorator *address { nullptr };
    static std::map<int, QString> contactTypeMapper;
};

}

#endif
