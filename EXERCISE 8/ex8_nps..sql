CREATE TABLE nps_data (
  id SERIAL PRIMARY KEY,
  product_id INTEGER,
  nps_score INTEGER,
FOREIGN KEY (product_id) references products(product_id)
);

select * from nps_data


select p.product_id, p.product_name, nps_score
from nps_data n
join products p using (product_id)



WITH nps_summary AS (
  SELECT 
    p.product_id, p.product_name, 
    COUNT(*) AS total_responses,
    SUM(CASE WHEN nps_score BETWEEN 0 AND 6 THEN 1 ELSE 0 END) AS detractors,
    SUM(CASE WHEN nps_score BETWEEN 7 AND 8 THEN 1 ELSE 0 END) AS passives,
    SUM(CASE WHEN nps_score BETWEEN 9 AND 10 THEN 1 ELSE 0 END) AS promoters
  FROM nps_data n
	JOIN products p on n.product_id = p.product_id
  GROUP BY 1, 2
)
SELECT 
  product_id,
  product_name,
  total_responses,
  detractors,
  passives,
  promoters,
  ROUND(100 * (promoters - detractors) / total_responses::numeric, 2) || '%' AS nps_score,
  ROUND(100 * passives / total_responses::numeric, 2) || '%' AS passive_respondents
FROM nps_summary;



