SELECT c.id,
c.descricao as DRIVER,
 cnt_arm.descricao as ARMADOR,
   ti.descricao as 'Tipo Iso',
    op.descricao as 'Operação',
     qtde_cnt_possivel,
       dc.descricao as 'Classificação Driver', 
        f.descricao as cliente,
        dm_benef.descricao as beneficiario,
           data_encerramento,
            drive_espaco_tipo_carga_id,
             data_hora_validade,
              data_hora_ddl,
               super_testado,
                cfu.descricao as 'Forma de Uso',
                 referencia, observacao,
                  qtde_container_vazio_carga,
                   qtde_container_vazio_descarga,
                    qtde_container_cheio_carga,
                     qtde_container_cheio_descarga,
                      programacao_externa
                      
                       FROM drive_espacos c
                       left join empresas cnt_arm on cnt_arm.id = c.armador_id
                       left join empresas f on f.id = c.cliente_id
                       left join empresas dm_benef on dm_benef.id = c.beneficiario_id
                       left join operacoes op on op.id = c.operacao_id
                       left join tipo_isos ti on ti.id = c.tipo_iso_id
                       left join drive_espaco_classificacoes dc on dc.id = c.drive_espaco_classificacao_id
                       left join container_forma_usos cfu on cfu.id = c.container_forma_uso_id
                       where (({{text/DRIVER}}) = '' or (c.descricao like {{text/DRIVER}}))
	  