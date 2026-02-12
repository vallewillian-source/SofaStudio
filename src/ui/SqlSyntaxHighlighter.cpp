#include "SqlSyntaxHighlighter.h"

#include <QQuickTextDocument>
#include <QTextDocument>
#include <QTextFormat>

namespace {
QTextCharFormat makeFormat(const QColor& color, bool bold = false)
{
    QTextCharFormat format;
    format.setForeground(color);
    format.setFontWeight(bold ? QFont::DemiBold : QFont::Normal);
    return format;
}
}

SqlSyntaxHighlighter::SqlSyntaxHighlighter(QObject* parent)
    : QSyntaxHighlighter(parent)
{
    rebuildRules();
}

QQuickTextDocument* SqlSyntaxHighlighter::document() const
{
    return m_document;
}

void SqlSyntaxHighlighter::setDocument(QQuickTextDocument* document)
{
    if (m_document == document) return;
    m_document = document;
    QSyntaxHighlighter::setDocument(m_document ? m_document->textDocument() : nullptr);
    emit documentChanged();
    rehighlight();
}

QColor SqlSyntaxHighlighter::keywordColor() const
{
    return m_keywordColor;
}

void SqlSyntaxHighlighter::setKeywordColor(const QColor& color)
{
    if (m_keywordColor == color) return;
    m_keywordColor = color;
    rebuildRules();
    emit keywordColorChanged();
    rehighlight();
}

QColor SqlSyntaxHighlighter::stringColor() const
{
    return m_stringColor;
}

void SqlSyntaxHighlighter::setStringColor(const QColor& color)
{
    if (m_stringColor == color) return;
    m_stringColor = color;
    rebuildRules();
    emit stringColorChanged();
    rehighlight();
}

QColor SqlSyntaxHighlighter::numberColor() const
{
    return m_numberColor;
}

void SqlSyntaxHighlighter::setNumberColor(const QColor& color)
{
    if (m_numberColor == color) return;
    m_numberColor = color;
    rebuildRules();
    emit numberColorChanged();
    rehighlight();
}

QColor SqlSyntaxHighlighter::commentColor() const
{
    return m_commentColor;
}

void SqlSyntaxHighlighter::setCommentColor(const QColor& color)
{
    if (m_commentColor == color) return;
    m_commentColor = color;
    rebuildRules();
    emit commentColorChanged();
    rehighlight();
}

void SqlSyntaxHighlighter::highlightBlock(const QString& text)
{
    for (const auto& rule : m_rules) {
        auto it = rule.pattern.globalMatch(text);
        while (it.hasNext()) {
            const auto match = it.next();
            setFormat(match.capturedStart(), match.capturedLength(), rule.format);
        }
    }

    setCurrentBlockState(0);

    int startIndex = 0;
    if (previousBlockState() != 1) {
        const auto startMatch = m_commentStart.match(text);
        startIndex = startMatch.hasMatch() ? startMatch.capturedStart() : -1;
    } else {
        startIndex = 0;
    }

    const QTextCharFormat commentFormat = makeFormat(m_commentColor);
    while (startIndex >= 0) {
        const auto endMatch = m_commentEnd.match(text, startIndex);
        int commentLength = 0;
        if (endMatch.hasMatch()) {
            commentLength = endMatch.capturedStart() - startIndex + endMatch.capturedLength();
        } else {
            setCurrentBlockState(1);
            commentLength = text.length() - startIndex;
        }
        setFormat(startIndex, commentLength, commentFormat);
        if (endMatch.hasMatch()) {
            const auto nextStart = m_commentStart.match(text, startIndex + commentLength);
            startIndex = nextStart.hasMatch() ? nextStart.capturedStart() : -1;
        } else {
            startIndex = -1;
        }
    }
}

void SqlSyntaxHighlighter::rebuildRules()
{
    m_rules.clear();

    const auto keywordFormat = makeFormat(m_keywordColor, true);
    const auto stringFormat = makeFormat(m_stringColor);
    const auto numberFormat = makeFormat(m_numberColor);
    const auto commentFormat = makeFormat(m_commentColor);

    Rule keywordRule;
    keywordRule.pattern = QRegularExpression(
        R"(\b(SELECT|FROM|WHERE|JOIN|LEFT|RIGHT|INNER|OUTER|FULL|ON|AS|GROUP|BY|ORDER|HAVING|LIMIT|OFFSET|INSERT|INTO|VALUES|UPDATE|SET|DELETE|CREATE|ALTER|DROP|TABLE|VIEW|INDEX|PRIMARY|KEY|FOREIGN|REFERENCES|NOT|NULL|DEFAULT|UNIQUE|CHECK|AND|OR|IN|IS|LIKE|ILIKE|BETWEEN|EXISTS|CASE|WHEN|THEN|ELSE|END|DISTINCT|UNION|ALL|WITH|RETURNING|ASC|DESC|TRUE|FALSE)\b)",
        QRegularExpression::CaseInsensitiveOption
    );
    keywordRule.format = keywordFormat;
    m_rules.push_back(keywordRule);

    Rule stringRule;
    stringRule.pattern = QRegularExpression(R"('([^']|'')*')");
    stringRule.format = stringFormat;
    m_rules.push_back(stringRule);

    Rule numberRule;
    numberRule.pattern = QRegularExpression(R"(\b\d+(\.\d+)?\b)");
    numberRule.format = numberFormat;
    m_rules.push_back(numberRule);

    Rule lineCommentRule;
    lineCommentRule.pattern = QRegularExpression(R"(--[^\n]*)");
    lineCommentRule.format = commentFormat;
    m_rules.push_back(lineCommentRule);
}
