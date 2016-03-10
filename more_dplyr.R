## ------------------------------------------------------------------------
sites <- read.csv("http://www.epa.gov/sites/production/files/2014-01/nla2007_sampledlakeinformation_20091113.csv")

## ------------------------------------------------------------------------
names(sites)

## ------------------------------------------------------------------------
sites_sel<-sites %>%
  select(SITE_ID,LAKENAME,VISIT_NO,SITE_TYPE,WSA_ECO9,AREA_HA,DEPTHMAX)
head(sites_sel)

## ------------------------------------------------------------------------
#Ascending is default
sites_sel %>%
  arrange(DEPTHMAX) %>%
  head()
#Descending need desc()
sites_sel %>%
  arrange(desc(DEPTHMAX)) %>%
  head()
#By more than one column
sites_sel %>%
  arrange(WSA_ECO9,desc(DEPTHMAX))%>%
  head()

## ------------------------------------------------------------------------
sites_sel %>%
  filter(DEPTHMAX >= 50)

## ------------------------------------------------------------------------
sites_sel %>%
  filter(WSA_ECO9 == "NAP", DEPTHMAX >= 50)

## ------------------------------------------------------------------------
sites_sel %>%
  slice(c(1,2))
#or
sites_sel %>%
  slice(seq(1,nrow(sites_sel),100))

## ------------------------------------------------------------------------
sites_sel %>%
  rename(Ecoregion = WSA_ECO9, MaxDepth = DEPTHMAX)%>%
  head()

## ------------------------------------------------------------------------
sites_sel %>%
  distinct(WSA_ECO9)
#Returns the first row with the distinct value so order has an impact
sites_sel %>%
  arrange(desc(DEPTHMAX))%>%
  distinct(WSA_ECO9)

## ------------------------------------------------------------------------
set.seed(72)
#By Number
sites_sel %>%
  sample_n(10)

#By Fraction
sites_sel %>%
  sample_frac(0.01)

## ------------------------------------------------------------------------
#Add it to the other columns
sites_sel %>%
  mutate(volume = ((10000*AREA_HA) * DEPTHMAX)/3)%>%
  head()
#Create only the new column
sites_sel %>%
  transmute(mean_depth = (((10000*AREA_HA) * DEPTHMAX)/3)/(AREA_HA*10000)) %>%
  head()

## ------------------------------------------------------------------------
sites_sel %>%
  summarize(avg_depth = mean(DEPTHMAX,na.rm=T),
            n = n()) %>%
  head()

## ------------------------------------------------------------------------
sites_sel %>%
  group_by(WSA_ECO9)

## ------------------------------------------------------------------------
sites_sel %>%
  group_by(WSA_ECO9) %>%
  summarize(avg = mean(DEPTHMAX,na.rm = T),
            std_dev = sd(DEPTHMAX, na.rm = T),
            n = n())

## ------------------------------------------------------------------------
wq <- read.csv("http://www.epa.gov/sites/production/files/2014-10/nla2007_chemical_conditionestimates_20091123.csv")
wq_sel<-wq %>%
  select(SITE_ID,VISIT_NO,CHLA,NTL,PTL,TURB)
head(wq_sel)
sites_sel <- sites_sel %>% 
  filter(SITE_TYPE == "PROB_Lake")

## ------------------------------------------------------------------------
dim(sites_sel)
dim(wq_sel)

## ------------------------------------------------------------------------
sites_wq <- left_join(sites_sel,wq_sel)
dim(sites_wq)
head(sites_wq)

## ------------------------------------------------------------------------
wq_sites <- right_join(sites_sel,wq_sel)
dim(wq_sites)
head(wq_sites)

## ------------------------------------------------------------------------
#First manufacture some differences
wq_samp <- wq_sel %>%
  sample_frac(.75)
sites_samp <- sites_sel %>%
  sample_frac(.75)
dim(wq_samp)
dim(sites_samp)
#Then the inner_join
sites_wq_in <- inner_join(sites_samp,wq_samp)
dim(sites_wq_in)
head(sites_wq_in)

## ------------------------------------------------------------------------
sites_wq_all <- full_join(sites_sel, wq_sel)
dim(sites_wq_all)
head(sites_wq_all)

## ------------------------------------------------------------------------
#We need to load up the RSQLite package
library(RSQLite)
#Then connect
nla_sqlite <- src_sqlite("nla2007.sqlite3")
nla_sqlite
#List Tables
src_tbls(nla_sqlite)

## ------------------------------------------------------------------------
#Get it all
sites_sqlite <- tbl(nla_sqlite,"sites")
wq_sqlite <- tbl(nla_sqlite,"wq")

#Use some SQL
sites_qry <- tbl(nla_sqlite,sql("SELECT * FROM sites WHERE VISIT_NO == 1"))
sites_qry

## ------------------------------------------------------------------------
sites_sel_sqlite <- sites_sqlite %>% 
  select(SITE_ID,LAKENAME,VISIT_NO,SITE_TYPE,WSA_ECO9,AREA_HA,DEPTHMAX)

## ------------------------------------------------------------------------
object.size(sites_sel)
object.size(sites_sel_sqlite)

## ------------------------------------------------------------------------
sites_sel_collect <- sites_sel_sqlite %>%
  arrange(desc(AREA_HA))%>%
  collect()

## ------------------------------------------------------------------------
#A Bootstrapped sample
ecor_depth_stats <- sites_sel_collect %>% 
  group_by(WSA_ECO9) %>%
  sample_n(1000,replace=T) %>%
  summarize(avg = mean(DEPTHMAX, na.rm=TRUE),
          sd = sd(DEPTHMAX, na.rm=TRUE),
          boot_n = n())

#And write back to the database
src_tbls(nla_sqlite)
copy_to(nla_sqlite,ecor_depth_stats)
src_tbls(nla_sqlite)

## ----echo=FALSE,messages=FALSE,warning=FALSE-----------------------------
db_drop_table(nla_sqlite$con,table="ecor_depth_stats")

