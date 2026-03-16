package com.parking.utils;

import org.springframework.stereotype.Component;

/**
 * Snowflake ID生成器
 */
@Component
public class SnowflakeIdGenerator {

    // 起始时间戳 (2024-01-01)
    private final long startTimestamp = 1704067200000L;

    // 机器ID位数
    private final long workerIdBits = 5L;

    // 数据中心ID位数
    private final long datacenterIdBits = 5L;

    // 序列号位数
    private final long sequenceBits = 12L;

    // 机器ID最大值
    private final long maxWorkerId = ~(-1L << workerIdBits);

    // 数据中心ID最大值
    private final long maxDatacenterId = ~(-1L << datacenterIdBits);

    // 机器ID左移位数
    private final long workerIdShift = sequenceBits;

    // 数据中心ID左移位数
    private final long datacenterIdShift = sequenceBits + workerIdBits;

    // 时间戳左移位数
    private final long timestampLeftShift = sequenceBits + workerIdBits + datacenterIdBits;

    // 序列号掩码
    private final long sequenceMask = ~(-1L << sequenceBits);

    private long workerId;
    private long datacenterId;
    private long sequence = 0L;
    private long lastTimestamp = -1L;

    public SnowflakeIdGenerator() {
        this.workerId = 0;
        this.datacenterId = 0;
    }

    public SnowflakeIdGenerator(long workerId, long datacenterId) {
        if (workerId > maxWorkerId || workerId < 0) {
            throw new IllegalArgumentException("Worker ID can't be greater than " + maxWorkerId + " or less than 0");
        }
        if (datacenterId > maxDatacenterId || datacenterId < 0) {
            throw new IllegalArgumentException("Datacenter ID can't be greater than " + maxDatacenterId + " or less than 0");
        }
        this.workerId = workerId;
        this.datacenterId = datacenterId;
    }

    /**
     * 生成下一个ID
     */
    public synchronized long nextId() {
        long timestamp = timeGen();

        if (timestamp < lastTimestamp) {
            throw new RuntimeException("Clock moved backwards. Refusing to generate id for " +
                    (lastTimestamp - timestamp) + " milliseconds");
        }

        if (lastTimestamp == timestamp) {
            sequence = (sequence + 1) & sequenceMask;
            if (sequence == 0) {
                timestamp = tilNextMillis(lastTimestamp);
            }
        } else {
            sequence = 0L;
        }

        lastTimestamp = timestamp;

        return ((timestamp - startTimestamp) << timestampLeftShift) |
                (datacenterId << datacenterIdShift) |
                (workerId << workerIdShift) |
                sequence;
    }

    private long tilNextMillis(long lastTimestamp) {
        long timestamp = timeGen();
        while (timestamp <= lastTimestamp) {
            timestamp = timeGen();
        }
        return timestamp;
    }

    private long timeGen() {
        return System.currentTimeMillis();
    }
}
