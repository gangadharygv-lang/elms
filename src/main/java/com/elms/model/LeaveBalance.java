package com.elms.model;

import java.math.BigDecimal;

public class LeaveBalance {
    private int balanceId;
    private int userId;
    private int leaveTypeId;
    private String leaveTypeName;
    private String leaveTypeCode;
    private int year;
    private int totalEntitled;
    private BigDecimal daysTaken = BigDecimal.ZERO;
    private BigDecimal daysRemaining = BigDecimal.ZERO;
    private BigDecimal carriedForward = BigDecimal.ZERO;

    public int getBalanceId() {
        return balanceId;
    }

    public void setBalanceId(int balanceId) {
        this.balanceId = balanceId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getLeaveTypeId() {
        return leaveTypeId;
    }

    public void setLeaveTypeId(int leaveTypeId) {
        this.leaveTypeId = leaveTypeId;
    }

    public String getLeaveTypeName() {
        return leaveTypeName;
    }

    public void setLeaveTypeName(String leaveTypeName) {
        this.leaveTypeName = leaveTypeName;
    }

    public String getLeaveTypeCode() {
        return leaveTypeCode;
    }

    public void setLeaveTypeCode(String leaveTypeCode) {
        this.leaveTypeCode = leaveTypeCode;
    }

    public int getYear() {
        return year;
    }

    public void setYear(int year) {
        this.year = year;
    }

    public int getTotalEntitled() {
        return totalEntitled;
    }

    public void setTotalEntitled(int totalEntitled) {
        this.totalEntitled = totalEntitled;
    }

    public BigDecimal getDaysTaken() {
        return daysTaken;
    }

    public void setDaysTaken(BigDecimal daysTaken) {
        this.daysTaken = daysTaken;
    }

    public BigDecimal getDaysRemaining() {
        return daysRemaining;
    }

    public void setDaysRemaining(BigDecimal daysRemaining) {
        this.daysRemaining = daysRemaining;
    }

    public BigDecimal getCarriedForward() {
        return carriedForward;
    }

    public void setCarriedForward(BigDecimal carriedForward) {
        this.carriedForward = carriedForward;
    }
}
