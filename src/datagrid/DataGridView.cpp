#include "DataGridView.h"
#include <cmath>
#include <QMouseEvent>
#include <QHoverEvent>

namespace Sofa::DataGrid {

DataGridView::DataGridView(QQuickItem* parent)
    : QQuickPaintedItem(parent)
    , m_lineColor("#333333")
    , m_headerColor("#181818")
    , m_alternateRowColor(Qt::transparent)
    , m_selectionColor("#264F78")
    , m_textColor("#E0E0E0")
{
    setFlag(ItemHasContents, true);
    setClip(true);
    setAcceptedMouseButtons(Qt::LeftButton | Qt::RightButton);
    setAcceptHoverEvents(true);
    // Transparent background to let QML Theme.background show through
    setFillColor(Qt::transparent);
    
    m_gearIcon = new QSvgRenderer(QString(":/qt/qml/sofa/ui/assets/gear-solid-full.svg"), this);
}

void DataGridView::hoverMoveEvent(QHoverEvent* event)
{
    if (!m_engine) return;

    double y = event->position().y();
    double x = event->position().x();

    // Check if over header
    if (y < m_rowHeight) {
        if (x < m_gutterWidth) {
            if (m_hoveredHeaderColumn != -1) {
                m_hoveredHeaderColumn = -1;
                update();
            }
            return;
        }

        double absoluteX = (x - m_gutterWidth) + m_contentX;
        int col = -1;
        double currentX = 0;
        
        for (int c = 0; c < m_engine->columnCount(); ++c) {
            auto colInfo = m_engine->getColumn(c);
            double w = colInfo.displayWidth;
            if (absoluteX >= currentX && absoluteX < currentX + w) {
                col = c;
                break;
            }
            currentX += w;
        }
        
        if (m_hoveredHeaderColumn != col) {
            m_hoveredHeaderColumn = col;
            update(); // Optimally: update(0, 0, width(), m_rowHeight);
        }
    } else {
        if (m_hoveredHeaderColumn != -1) {
            m_hoveredHeaderColumn = -1;
            update();
        }
    }
    
    QQuickPaintedItem::hoverMoveEvent(event);
}

void DataGridView::hoverLeaveEvent(QHoverEvent* event)
{
    if (m_hoveredHeaderColumn != -1) {
        m_hoveredHeaderColumn = -1;
        update();
    }
    QQuickPaintedItem::hoverLeaveEvent(event);
}

void DataGridView::mousePressEvent(QMouseEvent* event)
{
    if (!m_engine) return;
    
    double x = event->position().x();
    double y = event->position().y();
    
    if (event->button() == Qt::RightButton) {
        if (y < m_rowHeight) {
            return;
        }
        
        double absoluteY = y - m_rowHeight + m_contentY;
        int row = static_cast<int>(floor(absoluteY / m_rowHeight));
        
        if (row < 0 || row >= m_engine->rowCount()) {
            return;
        }

        if (x < m_gutterWidth) return;
        
        double absoluteX = (x - m_gutterWidth) + m_contentX;
        int col = -1;
        double currentX = 0;
        
        for (int c = 0; c < m_engine->columnCount(); ++c) {
            auto colInfo = m_engine->getColumn(c);
            double w = colInfo.displayWidth;
            if (absoluteX >= currentX && absoluteX < currentX + w) {
                col = c;
                break;
            }
            currentX += w;
        }
        
        if (col != -1) {
            if (m_selectedRow != row || m_selectedCol != col) {
                m_selectedRow = row;
                m_selectedCol = col;
                update();
            }
            emit cellContextMenuRequested(row, col, x, y);
        }
        return;
    }
    
    // Check if header clicked
    if (y < m_rowHeight) {
        if (x < m_gutterWidth) return;

        // Calculate Col
        double absoluteX = (x - m_gutterWidth) + m_contentX;
        int col = -1;
        double currentX = 0;
        
        for (int c = 0; c < m_engine->columnCount(); ++c) {
            auto colInfo = m_engine->getColumn(c);
            double w = colInfo.displayWidth;
            
            if (absoluteX >= currentX && absoluteX < currentX + w) {
                col = c;
                
                // Check if clicked on Gear Icon
                if (col == m_hoveredHeaderColumn) {
                    int iconSize = 14;
                    int padding = 6;
                    // Icon X in logical coords
                    double iconLogicalX = currentX + w - iconSize - padding;
                    
                    // Check bounds
                    if (absoluteX >= iconLogicalX && absoluteX <= iconLogicalX + iconSize) {
                        emit columnSettingsClicked(col);
                        return; // Handled
                    }
                }
                
                break;
            }
            currentX += w;
        }
        return;
    }
    
    // Calculate Row
    double absoluteY = y - m_rowHeight + m_contentY;
    int row = static_cast<int>(floor(absoluteY / m_rowHeight));
    
    if (row < 0 || row >= m_engine->rowCount()) {
        if (m_selectedRow != -1) {
            m_selectedRow = -1;
            m_selectedCol = -1;
            update();
        }
        return;
    }
    
    // Calculate Col
    if (x < m_gutterWidth) return;

    double absoluteX = (x - m_gutterWidth) + m_contentX;
    int col = -1;
    double currentX = 0;
    
    for (int c = 0; c < m_engine->columnCount(); ++c) {
        auto colInfo = m_engine->getColumn(c);
        
        double w = colInfo.displayWidth;
        if (absoluteX >= currentX && absoluteX < currentX + w) {
            col = c;
            break;
        }
        currentX += w;
    }
    
    if (col != -1) {
        if (m_selectedRow != row || m_selectedCol != col) {
            m_selectedRow = row;
            m_selectedCol = col;
            update();
        }
    }
}

void DataGridView::setEngine(DataGridEngine* engine)
{
    if (m_engine == engine) return;
    
    if (m_engine) {
        disconnect(m_engine, nullptr, this, nullptr);
    }
    
    m_engine = engine;
    
    if (m_engine) {
        connect(m_engine, &DataGridEngine::dataChanged, this, &DataGridView::onEngineUpdated);
        connect(m_engine, &DataGridEngine::layoutChanged, this, &DataGridView::onEngineUpdated);
    }
    
    emit engineChanged();
    onEngineUpdated();
}

void DataGridView::onEngineUpdated()
{
    emit contentSizeChanged();
    update();
}

void DataGridView::setContentY(double y)
{
    if (std::abs(m_contentY - y) > 0.1) {
        m_contentY = y;
        emit contentYChanged();
        update();
    }
}

void DataGridView::setContentX(double x)
{
    if (std::abs(m_contentX - x) > 0.1) {
        m_contentX = x;
        emit contentXChanged();
        update();
    }
}

void DataGridView::setRowHeight(double h)
{
    if (m_rowHeight != h) {
        m_rowHeight = h;
        emit rowHeightChanged();
        emit contentSizeChanged();
        update();
    }
}

void DataGridView::setHeaderColor(const QColor& c)
{
    if (m_headerColor != c) {
        m_headerColor = c;
        emit headerColorChanged();
        update();
    }
}

void DataGridView::setAlternateRowColor(const QColor& c)
{
    if (m_alternateRowColor != c) {
        m_alternateRowColor = c;
        emit alternateRowColorChanged();
        update();
    }
}

void DataGridView::setSelectionColor(const QColor& c)
{
    if (m_selectionColor != c) {
        m_selectionColor = c;
        emit selectionColorChanged();
        update();
    }
}

void DataGridView::setGridLineColor(const QColor& c)
{
    if (m_lineColor != c) {
        m_lineColor = c;
        emit gridLineColorChanged();
        update();
    }
}

void DataGridView::setTextColor(const QColor& c)
{
    if (m_textColor != c) {
        m_textColor = c;
        emit textColorChanged();
        update();
    }
}

double DataGridView::totalHeight() const
{
    if (!m_engine) return 0;
    // Header + rows
    return m_rowHeight + (m_engine->rowCount() * m_rowHeight);
}

double DataGridView::totalWidth() const
{
    if (!m_engine) return 0;
    return m_engine->totalWidth() + m_gutterWidth;
}

void DataGridView::paint(QPainter* painter)
{
    if (!m_engine) return;
    
    // Geometry
    double w = width();
    double h = height();
    int cols = m_engine->columnCount();
    
    // Draw Data
    int startRow = static_cast<int>(floor(m_contentY / m_rowHeight));
    int endRow = static_cast<int>(ceil((m_contentY + h) / m_rowHeight));
    if (startRow < 0) startRow = 0;
    if (endRow > m_engine->rowCount()) endRow = m_engine->rowCount();
    
    painter->save();
    // Clip data area (below header, right of gutter)
    painter->setClipRect(m_gutterWidth, m_rowHeight, w - m_gutterWidth, h - m_rowHeight);
    
    double currentY = (startRow * m_rowHeight) - m_contentY + m_rowHeight;
    
    QFont font = painter->font();
    font.setPixelSize(12);
    painter->setFont(font);
    
    for (int r = startRow; r < endRow; ++r) {
        double currentX = m_gutterWidth - m_contentX;
        
        for (int c = 0; c < cols; ++c) {
            auto col = m_engine->getColumn(c);
            
            double colW = col.displayWidth;
            
            // Optimization: skip if col is out of view
            if (currentX + colW > m_gutterWidth && currentX < w) {
                // Draw Cell
                QRectF cellRect(currentX, currentY, colW, m_rowHeight);
                
                // Background (Zebra Striping)
                // Only if not selected (selection draws over it)
                if (r != m_selectedRow || c != m_selectedCol) {
                    if (r % 2 == 0 && m_alternateRowColor.alpha() > 0) {
                        painter->fillRect(cellRect, m_alternateRowColor);
                    }
                }

                // Selection
                if (r == m_selectedRow && c == m_selectedCol) {
                     painter->save();
                     painter->setPen(Qt::NoPen);
                     painter->setBrush(m_selectionColor);
                     // Inset slightly to make rounding visible and clean
                     painter->drawRoundedRect(cellRect.adjusted(1, 1, -1, -1), 4, 4);
                     painter->restore();
                }

                // Borders
                painter->setPen(m_lineColor);
                painter->drawRect(cellRect);
                
                // Text
                QVariant dataVal = m_engine->getData(r, c);
                bool isNull = dataVal.isNull();
                
                // Extra check: if empty string and not a text column, treat as null
                if (!isNull && dataVal.userType() == QMetaType::QString && dataVal.toString().isEmpty()) {
                    auto col = m_engine->getColumn(c);
                    // If it's not explicitly Text/Varchar/etc, assume empty means null for safety
                    if (col.type != Sofa::Core::DataType::Text) {
                        isNull = true;
                    }
                }
                
                QString text = isNull ? "NULL" : dataVal.toString();
                
                QColor cellTextColor = m_textColor;
                
                // If selected, force dark text for better contrast with the colored background
                if (r == m_selectedRow && c == m_selectedCol) {
                    cellTextColor = QColor("#000000"); // Black text for selection
                    
                    QFont selectedFont = font;
                    selectedFont.setPixelSize(font.pixelSize() + 1);
                    painter->setFont(selectedFont);
                    
                    if (isNull) {
                        cellTextColor.setAlphaF(0.5);
                    }
                } else {
                    cellTextColor.setAlphaF(isNull ? 0.5 : 0.9);
                    painter->setFont(font);
                }
                
                painter->setPen(cellTextColor);
                painter->drawText(cellRect.adjusted(8, 0, -5, 0), Qt::AlignLeft | Qt::AlignVCenter, text);
            }
            currentX += colW;
        }
        currentY += m_rowHeight;
    }
    
    painter->restore();
    
    // Draw Gutter (Row Numbers)
    painter->save();
    painter->setClipRect(0, m_rowHeight, m_gutterWidth, h - m_rowHeight);
    
    // Gutter Background
    painter->fillRect(0, m_rowHeight, m_gutterWidth, h - m_rowHeight, m_headerColor);
    
    // Reset font for numbers
    painter->setFont(font);
    
    currentY = (startRow * m_rowHeight) - m_contentY + m_rowHeight;
    
    for (int r = startRow; r < endRow; ++r) {
        QRectF numRect(0, currentY, m_gutterWidth, m_rowHeight);
        
        // Border
        painter->setPen(m_lineColor);
        painter->drawRect(numRect); // Draw box for consistency with header
        
        // Text
        painter->setPen(m_textColor);
        painter->drawText(numRect, Qt::AlignCenter, QString::number(r + 1));
        
        currentY += m_rowHeight;
    }
    painter->restore();

    // Draw Header (Sticky)
    painter->save();
    painter->setClipRect(m_gutterWidth, 0, w - m_gutterWidth, m_rowHeight);
    
    // Background
    painter->fillRect(m_gutterWidth, 0, w - m_gutterWidth, m_rowHeight, m_headerColor);
    
    double currentX = m_gutterWidth - m_contentX;
    for (int c = 0; c < cols; ++c) {
        auto col = m_engine->getColumn(c);
        
        double colW = col.displayWidth;
        
        if (currentX + colW > m_gutterWidth && currentX < w) {
            QRectF cellRect(currentX, 0, colW, m_rowHeight);
            
            // Border
            painter->setPen(m_lineColor);
            painter->drawRect(cellRect);
            
            // Text
            painter->setPen(m_textColor);
            QFont headerFont = font;
            headerFont.setBold(true);
            painter->setFont(headerFont);
            
            QString headerText = col.name;
            // Adjust text rect to avoid icon if present
            QRectF textRect = cellRect.adjusted(8, 0, -5, 0);
            
            if (c == m_hoveredHeaderColumn) {
                // Draw Gear Icon
                int iconSize = 14;
                int padding = 6;
                double iconX = cellRect.right() - iconSize - padding;
                double iconY = (m_rowHeight - iconSize) / 2.0;
                
                if (colW > iconSize + padding * 3) {
                    QRectF iconRect(iconX, iconY, iconSize, iconSize);
                    if (m_gearIcon && m_gearIcon->isValid()) {
                        m_gearIcon->render(painter, iconRect);
                    }
                    
                    // Reduce text area
                    textRect.setRight(iconX - padding);
                }
            }
            
            painter->drawText(textRect, Qt::AlignLeft | Qt::AlignVCenter, headerText);
        }
        currentX += colW;
    }
    painter->restore();
    
    // Draw Corner (Top-Left)
    QRectF cornerRect(0, 0, m_gutterWidth, m_rowHeight);
    painter->fillRect(cornerRect, m_headerColor);
    painter->setPen(m_lineColor);
    painter->drawRect(cornerRect);
}

}
