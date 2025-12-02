package com.jsprest.factory;

import org.springframework.stereotype.Component;
import java.util.HashMap;
import java.util.Map;

@Component
public class MapFactory {

    public Map<String, Object> createResponseMap() {
        return new HashMap<String, Object>();
    }
}

