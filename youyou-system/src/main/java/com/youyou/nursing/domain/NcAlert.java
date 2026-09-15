package com.youyou.nursing.domain;

/** 仪表盘预警 */
public class NcAlert
{
    /** red / yellow */
    private String level;
    private String title;
    private String hint;
    private String keywords;
    private Long kbId;

    public NcAlert() {}

    public NcAlert(String level, String title, String hint, String keywords)
    {
        this.level = level;
        this.title = title;
        this.hint = hint;
        this.keywords = keywords;
    }

    public String getLevel() { return level; }
    public void setLevel(String level) { this.level = level; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getHint() { return hint; }
    public void setHint(String hint) { this.hint = hint; }
    public String getKeywords() { return keywords; }
    public void setKeywords(String keywords) { this.keywords = keywords; }
    public Long getKbId() { return kbId; }
    public void setKbId(Long kbId) { this.kbId = kbId; }
}
