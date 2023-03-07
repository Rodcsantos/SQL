SELECT 
a.id,
DATE(a.data_hora_entrada) as entrada,
(case when a.modal_id = 2 then 'Rodo'
else 'Ferro'
end) as modal,
UPPER(case when cont.numero is not null then cont.numero
else 'Batendo Lata' end) as Container

FROM  resvs a 
LEFT JOIN programacoes b on a.programacao_id=b.id
LEFT JOIN resvs_containers rc ON rc.resv_id = a.id
LEFT JOIN containers cont ON cont.id = rc.container_id

