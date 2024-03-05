-- Qual modelo de máquina apresenta mais falhas.
SELECT
pmo.modelo,
COUNT(*) AS failure_count
FROM  processed_data.falha pf 
INNER JOIN processed_data.maquina pm  ON pf.id_maquina  = pm.id
INNER JOIN processed_data.modelo pmo ON pm.id_modelo = pmo.id 
GROUP  BY pmo.modelo 
ORDER BY failure_count DESC;

---------------------------------------------------------------------

-- Qual a quantidade de falhas por idade da máquina.
SELECT date_part('year', CURRENT_DATE) - pm.ano  AS age, COUNT(*)
FROM processed_data.falha pf
JOIN processed_data.maquina pm ON pf.id_maquina = pm.id
GROUP BY age
ORDER BY age ASC;

--------------------------------------------------------------------

-- Qual componente apresenta maior quantidade de falhas por máquina.
WITH ranked AS(
SELECT pm.id,pc.componente,
       COUNT(*) AS quantidade,
       dense_rank() OVER (PARTITION BY pm.id
       ORDER BY COUNT(*) DESC) AS rank
FROM processed_data.falha pf
INNER JOIN processed_data.componente pc ON pf.id_componente = pc.id
INNER JOIN processed_data.maquina pm ON pf.id_maquina = pm.id
GROUP BY pm.id, pc.componente
)
SELECT id,
       componente,
       quantidade
FROM ranked
WHERE rank = 1
ORDER BY id;

----------------------------------------------------------------

-- A média da idade das máquinas por modelo
SELECT pmod.modelo, AVG(date_part('year', current_date) - pm.ano) AS average_age
FROM processed_data.maquina pm
INNER JOIN processed_data.modelo pmod ON pm.id_modelo = pmod.id
GROUP BY pmod.modelo
ORDER BY average_age;

------------------------------------------------------------------

-- Quantidade de erro por tipo de erro e modelo da máquina.
SELECT pe.erro, pmod.modelo, COUNT(*) AS count
FROM processed_data.maquina_erro pme
INNER JOIN processed_data.erro pe ON pme.id_erro = pe.id
INNER JOIN processed_data.maquina pm ON pm.id = pme.id_maquina
INNER JOIN processed_data.modelo pmod ON pmod.id = pm.id_modelo
GROUP BY pe.erro, pmod.modelo
ORDER BY count DESC;

-- componente entre modelos
--select
--c.componente, m2.modelo , count(*) as failure_count
--from processed_data.falha f 
--join  processed_data.componente c on f.id_componente = c.id 
--join processed_data.maquina m on f.id_maquina = m.id 
--join processed_data.modelo m2 on m2.id = m.id_modelo 
--group by c.componente, m2.modelo 
--order by failure_count desc