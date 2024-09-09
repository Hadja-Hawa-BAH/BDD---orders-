-- A quoi correspond la table « order_line » ?
-- table principale qui contient la clé étrangère

-- - - A quoi sert la colonne « order_id » ?
-- clé étrangère qui permet de relier les orders/commandes à leur cutumers respectifs.


-- 1. Récupérer l’utilisateur ayant le prénom “Muriel” et le mot de passe “test11”, sachant
-- que l’encodage du mot de passe est effectué avec l’algorithme Sha1.
select * from client where first_name = 'Muriel' and password = encode(digest('test11', 'sha1'), 'hex');

-- 2. Récupérer la liste de tous les produits qui sont présents sur plusieurs commandes
select last_name from order_line;

-- 3. Enregistrer le prix total à l’intérieur de chaque ligne des commandes, en fonction du
-- prix unitaire et de la quantité (il vous faudra utiliser une requête de mise à jour d’une
-- table : « UPDATE TABLE »)
update
	order_line
set total_price = unit_price * quantity
where total_price = 0;

-- 4. Récupérer le montant total pour chaque commande et afficher la date de commande
-- ainsi que le nom et le prénom du client.
select ol.total_price,
c.purchase_date,
cl.last_name, cl.first_name 
from order_line ol 
join customer_order c on ol.order_id = c.id 
join client cl on c.client_id = cl.id;

-- 5. Récupérer le montant global de toutes les commandes, pour chaque mois.
select extract(month from co.purchase_date) as order_month,
sum(ol.unit_price * ol.quantity) as total
from customer_order co 
join order_line ol on co.id = ol.order_id
group by order_month
order by order_month;

-- Récupérer la liste des 10 clients qui ont effectué le plus grand montant de
-- commandes, et obtenir ce montant total pour chaque client.
select ol.last_name, sum(ol.unit_price * ol.quantity) as total_spent from order_line ol
join client c on ol.order_id = c.id
group by ol.last_name 
order by total_spent desc 
limit 10;
-- ou
select ol.last_name, sum(ol.unit_price * ol.quantity) as total_spent from order_line ol
join client c on ol.order_id = c.id
group by ol.last_name 
order by total_spent desc 
fetch first 10 row only;

-- 7. Récupérer le montant total des commandes pour chaque jour
select extract(day from co.purchase_date) as order_day,
sum(ol.unit_price * ol.quantity) as total
from customer_order co 
join order_line ol on co.id = ol.order_id
group by order_day
order by order_day;

-- 8. Ajouter une colonne intitulée “category” à la table contenant les commandes. Cette
-- colonne contiendra une valeur numérique (il faudra utiliser « ALTER TABLE »
alter table order_line 
add category int4;

-- 9. Enregistrer la valeur de la catégorie, en suivant les règles suivantes :
--  “1” pour les commandes de moins de 200€
--  “2” pour les commandes entre 200€ et 500€
--  “3” pour les commandes entre 500€ et 1.000€
-- “4” pour les commandes supérieures à 1.000€

update order_line 
set category = case 
	when total_price < 200 then 1
	when total_price between 200 and 500 then 2
	when total_price between 500 and 1.000 then 3
	else 4
end;