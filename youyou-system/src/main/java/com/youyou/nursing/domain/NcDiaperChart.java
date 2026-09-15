package com.youyou.nursing.domain;

import java.util.List;

public class NcDiaperChart
{
    private Integer todayCount;
    private Integer todayAbnormal;
    private List<NcChartPoint> days;

    public Integer getTodayCount() { return todayCount; }
    public void setTodayCount(Integer todayCount) { this.todayCount = todayCount; }
    public Integer getTodayAbnormal() { return todayAbnormal; }
    public void setTodayAbnormal(Integer todayAbnormal) { this.todayAbnormal = todayAbnormal; }
    public List<NcChartPoint> getDays() { return days; }
    public void setDays(List<NcChartPoint> days) { this.days = days; }
}
