-- name: code_hotspots.default
WITH per_node AS (
    SELECT
        COALESCE(NULLIF(s.name, ''), 'EMPTY_SYMBOLS') AS function_name,
        d.node_type,
        d.call_tree_id,
        MAX(CASE WHEN m.name = 'Periodic Samples (self)' THEN d.measurement_value ELSE 0 END) AS periodic_samples_self,
        MAX(CASE WHEN m.name = 'Periodic Samples (self) - percentage' THEN d.measurement_value ELSE 0 END) AS periodic_samples_self_percent
    FROM drilldown_1 d
    LEFT JOIN symbols s
        ON d.symbol_id = s.symbol_id
    LEFT JOIN drilldown_measurements_1 m
        ON d.measurement_id = m.measurement_id
    GROUP BY d.call_tree_id, s.name, d.node_type
),
agg AS (
    SELECT
        function_name,
        node_type,
        SUM(periodic_samples_self)         AS periodic_samples_self,
        SUM(periodic_samples_self_percent) AS periodic_samples_self_percent
    FROM per_node
    GROUP BY function_name, node_type
)
SELECT
    a.function_name,
    a.node_type,
    a.periodic_samples_self,
    a.periodic_samples_self_percent
FROM agg a
ORDER BY a.periodic_samples_self DESC LIMIT 10;

-- name: instruction_mix.default
SELECT *
FROM flat_table;

-- name: cpu_microarchitecture.default
SELECT
    dm1.NAME AS metric,
    dm1.UNITS AS units,
    d1.MEASUREMENT_VALUE AS value
FROM drilldown_1 d1
JOIN drilldown_measurements_1 dm1
    ON d1.MEASUREMENT_ID = dm1.MEASUREMENT_ID
WHERE d1.CALL_TREE_ID = 0
ORDER BY value DESC;

-- name: memory_access.default
SELECT *
FROM drilldown;
