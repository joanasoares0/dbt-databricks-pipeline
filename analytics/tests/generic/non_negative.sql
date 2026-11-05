{#-
    Custom generic test: checks that a column has no negative values.

    Like dbt's built-in tests, it returns the rows that FAIL, so zero rows
    means the test passes. 
    
    Because it lives in tests/generic/, you can add it
    to any column in a properties .yml file, just like `not_null` or `unique`.
-#}

{% test non_negative(model, column_name) %}

SELECT *
FROM {{ model }}
WHERE {{ column_name }} < 0

{% endtest %}