#pragma once

#include <QColor>
#include <QRegularExpression>
#include <QSyntaxHighlighter>
#include <QTextCharFormat>
#include <QVector>
#include <QtQuick/QQuickTextDocument>
#include <QtQmlIntegration/qqmlintegration.h>

class SqlSyntaxHighlighter : public QSyntaxHighlighter
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QQuickTextDocument* document READ document WRITE setDocument NOTIFY documentChanged)
    Q_PROPERTY(QColor keywordColor READ keywordColor WRITE setKeywordColor NOTIFY keywordColorChanged)
    Q_PROPERTY(QColor stringColor READ stringColor WRITE setStringColor NOTIFY stringColorChanged)
    Q_PROPERTY(QColor numberColor READ numberColor WRITE setNumberColor NOTIFY numberColorChanged)
    Q_PROPERTY(QColor commentColor READ commentColor WRITE setCommentColor NOTIFY commentColorChanged)

public:
    explicit SqlSyntaxHighlighter(QObject* parent = nullptr);

    QQuickTextDocument* document() const;
    void setDocument(QQuickTextDocument* document);

    QColor keywordColor() const;
    void setKeywordColor(const QColor& color);

    QColor stringColor() const;
    void setStringColor(const QColor& color);

    QColor numberColor() const;
    void setNumberColor(const QColor& color);

    QColor commentColor() const;
    void setCommentColor(const QColor& color);

signals:
    void documentChanged();
    void keywordColorChanged();
    void stringColorChanged();
    void numberColorChanged();
    void commentColorChanged();

protected:
    void highlightBlock(const QString& text) override;

private:
    struct Rule {
        QRegularExpression pattern;
        QTextCharFormat format;
    };

    void rebuildRules();

    QQuickTextDocument* m_document = nullptr;
    QColor m_keywordColor = QColor("#74B9FF");
    QColor m_stringColor = QColor("#98C379");
    QColor m_numberColor = QColor("#F6C177");
    QColor m_commentColor = QColor("#7A7F87");
    QVector<Rule> m_rules;
    QRegularExpression m_commentStart = QRegularExpression(R"(/\*)");
    QRegularExpression m_commentEnd = QRegularExpression(R"(\*/)");
};
