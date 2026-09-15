package com.youyou.nursing.service.impl;

import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import com.youyou.nursing.domain.NcChartPoint;

public final class NursingChartHelper
{
    private NursingChartHelper()
    {
    }

    public static List<NcChartPoint> fillDays(List<NcChartPoint> rows, int days)
    {
        Map<String, NcChartPoint> map = new HashMap<String, NcChartPoint>();
        if (rows != null)
        {
            for (NcChartPoint row : rows)
            {
                map.put(row.getLabel(), row);
            }
        }
        List<NcChartPoint> result = new ArrayList<NcChartPoint>();
        Calendar calendar = Calendar.getInstance();
        calendar.add(Calendar.DATE, -(days - 1));
        SimpleDateFormat fmt = new SimpleDateFormat("yyyy-MM-dd");
        for (int i = 0; i < days; i++)
        {
            String key = fmt.format(calendar.getTime());
            NcChartPoint point = map.get(key);
            if (point == null)
            {
                point = new NcChartPoint(key, Integer.valueOf(0), BigDecimal.ZERO, Integer.valueOf(0));
            }
            else
            {
                if (point.getCount() == null)
                {
                    point.setCount(Integer.valueOf(0));
                }
                if (point.getAmount() == null)
                {
                    point.setAmount(BigDecimal.ZERO);
                }
                if (point.getExtra() == null)
                {
                    point.setExtra(Integer.valueOf(0));
                }
            }
            result.add(point);
            calendar.add(Calendar.DATE, 1);
        }
        return result;
    }

    public static List<NcChartPoint> fillHours(List<NcChartPoint> rows)
    {
        Map<String, NcChartPoint> map = new HashMap<String, NcChartPoint>();
        if (rows != null)
        {
            for (NcChartPoint row : rows)
            {
                map.put(row.getLabel(), row);
            }
        }
        List<NcChartPoint> result = new ArrayList<NcChartPoint>();
        for (int h = 0; h < 24; h++)
        {
            String key = String.valueOf(h);
            NcChartPoint point = map.get(key);
            if (point == null)
            {
                point = new NcChartPoint(key, Integer.valueOf(0), BigDecimal.ZERO, Integer.valueOf(0));
            }
            result.add(point);
        }
        return result;
    }
}
