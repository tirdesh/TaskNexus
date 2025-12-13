package com.jsprest.entity.enums;

public enum ProjectStatus {
    PLANNING,
    IN_PROGRESS,
    COMPLETED,
    ON_HOLD;

    public String getName() {
        return this.name();
    }
}
