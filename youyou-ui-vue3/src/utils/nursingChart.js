import * as echarts from "echarts"

const PRI = "#DE8F74"
const INFO = "#5E87A8"
const OK = "#6E9E7E"

export function axisDates(rows) {
  return (rows || []).map(item => (item.label || "").slice(5))
}

export function lineBarOption(xData, series, yName) {
  return {
    color: [PRI, INFO, OK],
    tooltip: { trigger: "axis" },
    legend: { top: 0 },
    grid: { left: 44, right: 16, top: 32, bottom: 28 },
    xAxis: { type: "category", data: xData, axisLabel: { fontSize: 10 } },
    yAxis: { type: "value", name: yName, minInterval: 1 },
    series
  }
}

export function bindChart(holder, instance) {
  if (!holder) {
    return instance
  }
  if (!instance) {
    instance = echarts.init(holder)
  }
  return instance
}

export function disposeChart(instance) {
  if (instance) {
    instance.dispose()
  }
  return null
}

export function avatarSrc(path) {
  if (!path) {
    return ""
  }
  if (/^https?:\/\//.test(path)) {
    return path
  }
  return import.meta.env.VITE_APP_BASE_API + path
}

export function nameInitial(name) {
  const text = (name || "?").trim()
  return text ? text.slice(0, 1) : "?"
}

export function isAbnormalStool(value) {
  return ["watery", "bloody", "mucus", "other"].includes(value)
}

export function sootheRate(row) {
  const used = Number(row.count || 0)
  const ok = Number(row.extra || 0)
  if (!used) {
    return 0
  }
  return Math.round((ok / used) * 100)
}
