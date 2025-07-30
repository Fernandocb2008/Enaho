*Nota: para calculo de indicadores sociales filtrar miembros del hogar
*Para tener mejores estimacionaes de población absoluta usar residente habitual
*Siempre se recomienda revisar los cuestionarios

********* Tasa de enfermedad crónica Anual *****
*Documento condiciones de vida 2019 (pag 21)

use enaho01a-2019-400, clear

drop if codinfor=="00" //los missing no entran al calculo de indicadores
keep if p204==1 //solo miembros

gen factor2=round(factor07,2)

tab p401,m 

gen enf_cronica=0
replace enf_cronica=100 if (enf_cronica==0 & p401==1)
tab enf_cronica,m

lab def enf_cronica 100 "Con enfermedad crónica" 0 "Sin enfermedad crónica"
lab val enf_cronica enf_cronica

*Indicador
tabstat enf_cronica [fw=factor2], s(mean) by(p207) format(%4.1f) 

*Población (lectura 12,800,000)
gen pob=1
table enf_cronica [fw=factor2], c(sum pob) row format(%10.0fc)

*Intervalos de confianza
svyset [pweight = factor07], psu(conglome) strata(estrato)
svy: mean enf_cronica 
svy: mean enf_cronica,  over(p207) 

*Diferencia de medias
svy: mean enf_cronica,  over(p207) 
lincom enf_cronica@2.p207 - enf_cronica@1.p207

****** TIPOS DE INDICADORES ****

*1. Promedios, ejm: Años de educación/N° personas

*2. Porcentaje (proporción), ejm:  (Población Analfabeta/población de 15 a más años)*100 

*3. Ratios, Ejem: Productividad del cafe= (Producción de cafe (T)/Tierra cosechada (Ha))

*Tabulados en base a categorías de interés o creadas

********* Tasa de enfermedad crónica con data Trimestral *****
*II Trimestre 2020
use enaho01a_2019_400_4trim, clear

*Append con II trimestre 2020
append using enaho01a_2018_400_4trim

drop if codinfor=="00" //los missing no entran al calculo de indicadores
gen factor2=round(factor,2)

*Para los indicadores el techo (denominador) es miembros del hogar
keep if p204==1

*Región o departamento
gen ubigeo1=substr(ubigeo,1,2) //Extracción de código de región
gen region=real(ubigeo1) //Conversión a dato numérico
drop ubigeo1

lab def region 1 "Amazonas" 2 "Áncash" 3 "Apurímac" 4 "Arequipa" 5 "Ayacucho" 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huánuco" 11 "Ica" 12 "Junín" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" 17 "Madre de Dios" 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martin" 23 "Tacna" 24 "Tumbes" 25 "Ucayali"
label val region region

*Área geográfica
replace estrato =1 if dominio==8
recode estrato (1/5=1)(6/8=0), gen(area)
lab def area 1 "Urbano" 0 "Rural"
lab val area area

**Generamos indicador
*tabulado para ver la variable
tab p401,m 

gen enf_cronica=0
replace enf_cronica=100 if (enf_cronica==0 & p401==1)

tab enf_cronica,m

lab def enf_cronica 100 "Con enfermedad crónica" 0 "Sin enfermedad crónica"
lab val enf_cronica enf_cronica

table area aÑo [pw=factor],c(mean enf_cronica) row format(%4.1f)
table area aÑo [fw=factor2],c(mean enf_cronica) row format(%4.1f)
tabstat enf_cronica [fw=factor2], by(aÑo) format(%4.1f)

destring aÑo, gen(año)

*Intervalos de confianza
svyset [pweight = factor2], psu(conglome) strata(estrato)
svy: mean enf_cronica, over(año)

*Coeficiente de variación (error estandar/estimador)
*El estimador es referencial por tener alta variabilidad cuando el CV es mayor al 15%
*CV del indicador estimado del IV trim 2019
display 0.6125596/37.75537 *100 //1.6%

*Diferencia de medias
svy: mean enf_cronica,  over(año) 
lincom enf_cronica@2019.año - enf_cronica@2018.año 
*lincom [enf_cronica]mujer - [enf_cronica]hombre //version hasta stata15

*Ver tamaño de muestra
tab enf_cronica año

******* INDICADOR: Síntoma o enfermedad temporal (4 últimas semanas)
use enaho01a-2019-400, clear
drop if codinfor=="00" 
gen factor2=round(factor07,2)
keep if p204==1 //solo miembros

tab p4025,m
tab p4025,m nolab

destring aÑo,gen(año)

*Área geográfica
replace estrato =1 if dominio==8
recode estrato (1/5=1)(6/8=0), gen(area)
lab def area 1 "Urbano" 0 "Rural"
lab val area area

*Indicador
gen enf_temporal=0
replace enf_temporal=100 if (enf_temporal==0 & p4025==0)

tab enf_temporal,m

lab def enf_temporal 100 "Con enfermedad temporal" 0 "Sin enfermedad temporal"
lab val enf_temporal enf_temporal

table area [pw=factor07],c(mean enf_temporal) row format(%4.1f)
tabstat enf_temporal [fw=factor2], by(area) format(%4.1f)

**** INDICADOR: Afiliación a algún seguro de salud
use enaho01a-2018-400, clear
drop if codinfor=="00" 
gen factor2=round(factor07,2)
keep if p204==1 //solo miembros

*Área geográfica
replace estrato =1 if dominio==8
recode estrato (1/5=1)(6/8=0), gen(area)
lab def area 1 "Urbano" 0 "Rural"
lab val area area

*indicador
gen con_seguro=0 
replace con_seguro=100 if (p4191==1 | p4192==1  | p4193==1 | p4194==1 | p4195==1  | p4196==1 | p4197==1 | p4198==1) 
 
lab def con_seguro 100 "Con seguro" 0 "Sin seguro"
lab val con_seguro con_seguro

table area [pw=factor07],c(mean con_seguro) row format(%4.1f)
tab con_seguro area [fw=factor2],col
tabstat con_seguro [fw=factor2], by(area) format(%4.1f)

*Intervalos de confianza
svyset [pweight = factor07], psu(conglome) strata(estrato)
svy: mean con_seguro
svy: mean con_seguro,  over(area)

******** // Tabulados // ***
*Tenencia de DNI
tab p401c [fw= factor2]

*Indicadores a partir de preguntas
tab p401c, gen(dni)

