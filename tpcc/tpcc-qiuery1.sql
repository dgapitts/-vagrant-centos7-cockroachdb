
explain analyze 
SELECT
      ol_d_id, ol_w_id
    sum(ol_quantity) as sum_qty,
    sum(ol_amount) as sum_base_price,
    count(*) as count_order
FROM
    order_line
WHERE
    ol_delivery_d <= date '1998-12-01' - interval '90' day
GROUP BY
    ol_d_id, ol_w_id
ORDER BY
      ol_d_id, ol_w_id



