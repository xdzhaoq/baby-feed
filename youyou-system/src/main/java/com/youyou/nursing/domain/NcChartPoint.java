package com.youyou.nursing.domain;

import java.math.BigDecimal;

/** 护理趋势图数据点 */
public class NcChartPoint
{
    private String label;
    private Integer count;
    private BigDecimal amount;
    private Integer extra;

    public NcChartPoint()
    {
    }

    public NcChartPoint(String label, Integer count, BigDecimal amount, Integer extra)
    {
        this.label = label;
        this.count = count;
        this.amount = amount;
        this.extra = extra;
    }

    public String getLabel() { return label; }
    public void setLabel(String label) { this.label = label; }
    public Integer getCount() { return count; }
    public void setCount(Integer count) { this.count = count; }
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    public Integer getExtra() { return extra; }
    public void setExtra(Integer extra) { this.extra = extra; }
}
