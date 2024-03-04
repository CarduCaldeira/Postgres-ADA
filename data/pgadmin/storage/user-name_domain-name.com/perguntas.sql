

-- Qual modelo de máquina apresenta mais falhas.
select
m2.modelo,
count(*) as failure_count
from  processed_data.falha f 
join processed_data.maquina m  on f.id_maquina  = m.id
join processed_data.modelo m2 on m.id_modelo = m2.id 
group  by m2.modelo 
order by failure_count desc;


-- Qual a quantidade de falhas por idade da máquina.
select date_part('year', current_date) - m.ano  as age,
       count(*) AS f_count
from processed_data.falha f
join processed_data.maquina m ON f.id_maquina = m.id
group by date_part('year', current_date)- m.ano 
order by age asc;


-- Qual componente apresenta maior quantidade de falhas por máquina.
WITH ranked AS(
   SELECT m.id,
          c.componente,
          COUNT(*) AS failure_count,
          dense_rank() OVER (PARTITION BY m.id
                             ORDER BY COUNT(*) DESC) AS rank
   FROM processed_data.falha f
   LEFT JOIN processed_data.componente c ON f.id_componente = c.id
   LEFT JOIN processed_data.maquina m ON f.id_maquina = m.id
   GROUP BY m.id,
            c.componente
)
SELECT id,
       componente,
       failure_count
FROM ranked
WHERE rank = 1
ORDER BY id;


-- A média da idade das máquinas por modelo
SELECT m2.modelo,
       avg(date_part('year', current_date) - m.ano) AS average_age
FROM processed_data.maquina m
LEFT JOIN processed_data.modelo m2 ON m.id_modelo = m2.id
GROUP BY m2.modelo
order by average_age;


-- Quantidade de erro por tipo de erro e modelo da máquina.
SELECT e.id,
       m2.modelo,
       count(*) AS COUNT
FROM processed_data.maquina_erro em
LEFT JOIN processed_data.erro e ON em.id_erro = e.id
LEFT JOIN processed_data.maquina m ON m.id = em.id_maquina
LEFT JOIN processed_data.modelo m2 ON m2.id = m.id_modelo
GROUP BY e.id,
         m2.modelo
ORDER BY COUNT desc;

-- componente entre modelos
--select
--c.componente, m2.modelo , count(*) as failure_count
--from processed_data.falha f 
--join  processed_data.componente c on f.id_componente = c.id 
--join processed_data.maquina m on f.id_maquina = m.id 
--join processed_data.modelo m2 on m2.id = m.id_modelo 
--group by c.componente, m2.modelo 
--order by failure_count desc