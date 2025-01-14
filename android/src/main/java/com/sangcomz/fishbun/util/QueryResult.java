package com.sangcomz.fishbun.util;

import java.util.ArrayList;

public class QueryResult {
    public ArrayList medias;
    public int queryCount;
    public boolean switchBucket;

    QueryResult(ArrayList result, int queryCount, boolean switchBucket) {
        this.medias = result;
        this.queryCount = queryCount;
        this.switchBucket = switchBucket;
    }
}
