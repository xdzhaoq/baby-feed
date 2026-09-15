package com.youyou.nursing.domain;

import java.util.List;

public class NcCryChart
{
    private List<NcChartPoint> hours;
    private List<NcChartPoint> soothe;

    public List<NcChartPoint> getHours() { return hours; }
    public void setHours(List<NcChartPoint> hours) { this.hours = hours; }
    public List<NcChartPoint> getSoothe() { return soothe; }
    public void setSoothe(List<NcChartPoint> soothe) { this.soothe = soothe; }
}
