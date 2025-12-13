package com.jsprest.entity.enums;

public enum TaskStatus {
    TODO,
    IN_PROGRESS,
    COMPLETED,
    BLOCKED;

    public String getName() {
        return this.name();
    }
}
