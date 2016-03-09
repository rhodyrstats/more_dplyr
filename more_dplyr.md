

# More fun with `dplyr`
These materials will go over some introductory materials (i.e. from our [Intro R Workshop](https://github.com/rhodyrstats/intro_r_workshop)) as well as expand into some of the other functionality.  This presentation is heavily influenced by the [Introduction to `dplyr`](https://cran.r-project.org/web/packages/dplyr/vignettes/introduction.html), the [Two-table Verbs](https://cran.r-project.org/web/packages/dplyr/vignettes/two-table.html), and [Databases](https://cran.r-project.org/web/packages/dplyr/vignettes/databases.html) vigenettes. In particular we will cover:

- [A word about pipes](#a-word-about-pipes)
- [Manipulating data](#manipulating-data)
- [Manipulating grouped data](#manipulating-grouped-data)
- [Database functionality: joins](#database-functionality-joins)
- [Database functionality: external databases](#database-functionality-external-databases)

## A word about pipes
There are many different ways to go about scripting an analyis in R (or any language for that matter).  These were discussed in the [Intro to R Workshop](https://github.com/rhodyrstats/intro_r_workshop/blob/master/lessons/03_wrangling.md#using-dplyr)(scroll down a bit), but to review, they are: using intermediate steps/objects, nest functions, or use pipes.  If you are developing new functions or packages it is probably best to not use pipes as it adds a dependency and de-bugging can be a bit of a challenge.  If you are scripting data analysis, pipes (i.e. `%>%` from `magrittr`) are, in my opinion, the way to go.  For this presentation we will use pipes for all the examples.

## Manipulating data
The `dplyr` package is first and foremost a package to help faciliatate data manipulation.  What it does can certainly be done with base R or with other packages, but it can be argued that `dplyr` makes these tasks more undertandable through its use of a consistent interface.  In particular, this is accomplished through the use of data manipulation verbs.  These verbs are:

- `select()`: selects columns from a data frame 
- `arrange()`: Arranges a data frame in ascending or descending order based on column(s). 
- `filter()`: Select observations from a data frame based on values in column(s).
- `slice()`: Selects observations based on specific rows 
- `rename()`: Rename columns in a dataframe
- `distinct()`: Get unique rows (OK, not a verb...) 
- `sample_n()`: Randomly select 'n' number of rows
- `sample_frac()`: Randomly select a fraction of rows 
- `mutate()`: Adds new columns to a data frame and keeps all other columns
- `transmutate()`: Adds new columns to a data frame and drops all other columns
- `summarise()`: Summarizes your data.

Before we move on, we need some data.  Once again, I am going to rely on the 2007 National Lakes Assessment Data:


```r
sites <- read.csv("http://www.epa.gov/sites/production/files/2014-01/nla2007_sampledlakeinformation_20091113.csv")
```

Let's look at the columns for each of these


```r
names(sites)
```

```
##  [1] "SITE_ID"         "VISIT_NO"        "SAMPLED"        
##  [4] "DATE_COL"        "REPEAT"          "SITE_TYPE"      
##  [7] "LAKE_SAMP"       "TNT"             "LON_DD"         
## [10] "LAT_DD"          "ALBERS_X"        "ALBERS_Y"       
## [13] "FLD_LON_DD"      "FLD_LAT_DD"      "FLD_SRC"        
## [16] "FLD_FLAG"        "ST"              "STATE_NAME"     
## [19] "CNTYNAME"        "EPA_REG"         "NHDNAME"        
## [22] "LAKENAME"        "AREA_CAT7"       "NESLAKE"        
## [25] "NESLAKE_ID"      "STRATUM"         "PANEL"          
## [28] "DSGN_CAT"        "MDCATY"          "WGT"            
## [31] "WGT_NLA"         "ADJWGT_CAT"      "URBAN"          
## [34] "WSA_ECO3"        "WSA_ECO9"        "ECO_LEV_3"      
## [37] "ECO_L3_NAM"      "NUT_REG"         "NUTREG_NAME"    
## [40] "ECO_NUTA"        "LAKE_ORIGIN"     "ECO3_X_ORIGIN"  
## [43] "REF_CLUSTER"     "REFCLUS_NAME"    "RT_NLA"         
## [46] "REF_NUTR"        "AREA_HA"         "SIZE_CLASS"     
## [49] "LAKEAREA"        "LAKEPERIM"       "SLD"            
## [52] "DEPTH_X"         "DEPTHMAX"        "ELEV_PT"        
## [55] "HUC_2"           "HUC_8"           "REACHCODE"      
## [58] "COM_ID"          "INDEX_SAMP"      "STATUS_VER"     
## [61] "STATUS_FLD"      "STATUS_DSK"      "PERM_WATER"     
## [64] "NON_SALINE"      "SRFC_AREA"       "METER_DEEP"     
## [67] "OPEN_WATER"      "AQUACULTUR"      "DISPOSAL"       
## [70] "SEWAGE"          "EVAPORATE"       "PHYS_ACCES"     
## [73] "FLAG_INFO"       "COMMENT_INFO"    "SAMPLED_PROFILE"
## [76] "SAMPLED_SECCHI"  "SAMPLED_ASSESS"  "SAMPLED_PHAB"   
## [79] "INDXSAMP_PHAB"   "SAMPLED_CHEM"    "INDXSAMP_CHEM"  
## [82] "SAMPLED_CHLA"    "INDXSAMP_CHLA"   "SAMPLED_ZOOP"   
## [85] "INDXSAMP_ZOOP"   "SAMPLED_PHYT"    "INDXSAMP_PHYT"  
## [88] "SAMPLED_CORE"    "INDXSAMP_CORE"   "SAMPLED_INF"    
## [91] "INDXSAMP_INF"    "SAMPLED_ENTE"    "INDXSAMP_ENTE"  
## [94] "SAMPLED_MICR"    "INDXSAMP_MICR"   "SAMPLED_SDHG"   
## [97] "INDXSAMP_SDHG"   "VISIT_ID"        "FID_1"
```

Given the large number of fields in these, I may want to reduce just to what I am interested in.


```r
sites_sel <- sites %>% select(SITE_ID, LAKENAME, VISIT_NO, SITE_TYPE, WSA_ECO9, 
    AREA_HA, DEPTHMAX)
head(sites_sel)
```

```
##         SITE_ID        LAKENAME VISIT_NO SITE_TYPE WSA_ECO9   AREA_HA
## 1 NLA06608-0001   Lake Wurdeman        1 PROB_Lake      WMT 66.293055
## 2 NLA06608-0002      Crane Pond        1 PROB_Lake      CPL 14.437998
## 3 NLA06608-0002      Crane Pond        2 PROB_Lake      CPL 14.437998
## 4 NLA06608-0003 Wilderness Lake        1 PROB_Lake      CPL  5.701737
## 5 NLA06608-0003 Wilderness Lake        2 PROB_Lake      CPL  5.701737
## 6 NLA06608-0004 Puett Reservoir        1 PROB_Lake      WMT 65.386309
##   DEPTHMAX
## 1      8.3
## 2      2.3
## 3      1.3
## 4      2.5
## 5      2.4
## 6      6.3
```

We can arrange the data.


```r
# Ascending is default
sites_sel %>% arrange(DEPTHMAX) %>% head()
```

```
##         SITE_ID      LAKENAME VISIT_NO SITE_TYPE WSA_ECO9  AREA_HA
## 1 NLA06608-0508 Grittman Lake        1 PROB_Lake      CPL 15.37348
## 2 NLA06608-2566  Chapman Pond        1 PROB_Lake      NAP 69.25805
## 3 NLA06608-0830  Unnamed Lake        1 PROB_Lake      NPL 44.89524
## 4 NLA06608-1596  Roundup Lake        1 PROB_Lake      SPL 51.21775
## 5 NLA06608-0029 Red Mill Pond        2 PROB_Lake      CPL 73.10037
## 6 NLA06608-0439                      1 PROB_Lake      NPL 17.48390
##   DEPTHMAX
## 1      0.5
## 2      0.5
## 3      0.6
## 4      0.7
## 5      0.8
## 6      0.9
```

```r
# Descending need desc()
sites_sel %>% arrange(desc(DEPTHMAX)) %>% head()
```

```
##         SITE_ID         LAKENAME VISIT_NO SITE_TYPE WSA_ECO9    AREA_HA
## 1 NLA06608-0433   Lake Champlain        1 PROB_Lake      NAP 107359.901
## 2 NLA06608-0129      Ashley Lake        1 PROB_Lake      WMT   1138.974
## 3 NLA06608-0021 Canandaigua Lake        1 PROB_Lake      NAP   4226.925
## 4 NLA06608-0561     Payette Lake        1 PROB_Lake      WMT   2018.423
## 5 NLA06608-1717     Lake Mcclure        1 PROB_Lake      XER   2267.070
## 6 NLA06608-1354     Bighorn Lake        1 PROB_Lake      NPL   5253.904
##   DEPTHMAX
## 1     97.0
## 2     60.3
## 3     53.0
## 4     52.5
## 5     51.0
## 6     50.2
```

```r
# By more than one column
sites_sel %>% arrange(WSA_ECO9, desc(DEPTHMAX)) %>% head()
```

```
##                SITE_ID                     LAKENAME VISIT_NO SITE_TYPE
## 1        NLA06608-3083         Livingston Reservoir        1 PROB_Lake
## 2        NLA06608-0283               Lake Demopolis        1 PROB_Lake
## 3        NLA06608-1047                  Sam Rayburn        1 PROB_Lake
## 4        NLA06608-R324       Little Creek Reservoir        1  REF_Lake
## 5 NLA06608-FL:16674741                 Sheeler Lake        1  REF_Lake
## 6        NLA06608-2091 R E 'Bob' Woodruff Reservoir        1 PROB_Lake
##   WSA_ECO9      AREA_HA DEPTHMAX
## 1      CPL 33757.391610     20.0
## 2      CPL  4731.475925     18.1
## 3      CPL 45650.689950     17.4
## 4      CPL   359.878020     16.0
## 5      CPL     7.770295     14.2
## 6      CPL  5325.718765     13.7
```

Let's filter out just some of the deeper lakes


```r
sites_sel %>% filter(DEPTHMAX >= 50)
```

```
##         SITE_ID         LAKENAME VISIT_NO SITE_TYPE WSA_ECO9    AREA_HA
## 1 NLA06608-0021 Canandaigua Lake        1 PROB_Lake      NAP   4226.925
## 2 NLA06608-0129      Ashley Lake        1 PROB_Lake      WMT   1138.974
## 3 NLA06608-0401        Long Lake        1 PROB_Lake      NAP   2677.178
## 4 NLA06608-0433   Lake Champlain        1 PROB_Lake      NAP 107359.901
## 5 NLA06608-0561     Payette Lake        1 PROB_Lake      WMT   2018.423
## 6 NLA06608-0794    Freemont Lake        1 PROB_Lake      WMT   2045.332
## 7 NLA06608-1354     Bighorn Lake        1 PROB_Lake      NPL   5253.904
## 8 NLA06608-1717     Lake Mcclure        1 PROB_Lake      XER   2267.070
##   DEPTHMAX
## 1     53.0
## 2     60.3
## 3     50.0
## 4     97.0
## 5     52.5
## 6     50.0
## 7     50.2
## 8     51.0
```

Or just the deep lakes in Northern Applachians Ecoregion


```r
sites_sel %>% filter(WSA_ECO9 == "NAP", DEPTHMAX >= 50)
```

```
##         SITE_ID         LAKENAME VISIT_NO SITE_TYPE WSA_ECO9    AREA_HA
## 1 NLA06608-0021 Canandaigua Lake        1 PROB_Lake      NAP   4226.925
## 2 NLA06608-0401        Long Lake        1 PROB_Lake      NAP   2677.178
## 3 NLA06608-0433   Lake Champlain        1 PROB_Lake      NAP 107359.901
##   DEPTHMAX
## 1       53
## 2       50
## 3       97
```

We can also grab observations by row


```r
sites_sel %>% slice(c(1, 2))
```

```
##         SITE_ID      LAKENAME VISIT_NO SITE_TYPE WSA_ECO9  AREA_HA
## 1 NLA06608-0001 Lake Wurdeman        1 PROB_Lake      WMT 66.29306
## 2 NLA06608-0002    Crane Pond        1 PROB_Lake      CPL 14.43800
##   DEPTHMAX
## 1      8.3
## 2      2.3
```

```r
# or
sites_sel %>% slice(seq(1, nrow(sites_sel), 100))
```

```
##          SITE_ID                                     LAKENAME VISIT_NO
## 1  NLA06608-0001                                Lake Wurdeman        1
## 2  NLA06608-0081                               Armstrong Lake        1
## 3  NLA06608-0221                                   Jolly Pond        1
## 4  NLA06608-0402                                  Powers Pond        1
## 5  NLA06608-0593                                  Lake Louise        1
## 6  NLA06608-0794                                Freemont Lake        2
## 7  NLA06608-0984 Whitegrass-Waterhole Creeks Site 9 Reservoir        1
## 8  NLA06608-1204                                Hamilton Lake        1
## 9  NLA06608-1414                             Bissonnette Pond        1
## 10 NLA06608-1717                                 Lake Mcclure        1
## 11 NLA06608-2155                                     Fox Lake        1
## 12 NLA06608-3484                              Big Alkali Lake        1
## 13 NLA06608-R314                                 Holiday Lake        1
##    SITE_TYPE WSA_ECO9    AREA_HA DEPTHMAX
## 1  PROB_Lake      WMT   66.29306      8.3
## 2  PROB_Lake      WMT   10.00704      8.5
## 3  PROB_Lake      CPL   18.43276      2.1
## 4  PROB_Lake      WMT    7.45115      2.3
## 5  PROB_Lake      WMT   10.31473     26.5
## 6  PROB_Lake      WMT 2045.33182     46.0
## 7  PROB_Lake      CPL   10.43687      1.5
## 8  PROB_Lake      SAP 2506.86740     30.0
## 9  PROB_Lake      NAP   19.46023      2.4
## 10 PROB_Lake      XER 2267.07042     51.0
## 11 PROB_Lake      UMW   53.02914     17.7
## 12 PROB_Lake      SPL  363.50473      1.9
## 13  REF_Lake      SAP   46.65278      5.3
```

Renaming columns is easy


```r
sites_sel %>% rename(Ecoregion = WSA_ECO9, MaxDepth = DEPTHMAX) %>% head()
```

```
##         SITE_ID        LAKENAME VISIT_NO SITE_TYPE Ecoregion   AREA_HA
## 1 NLA06608-0001   Lake Wurdeman        1 PROB_Lake       WMT 66.293055
## 2 NLA06608-0002      Crane Pond        1 PROB_Lake       CPL 14.437998
## 3 NLA06608-0002      Crane Pond        2 PROB_Lake       CPL 14.437998
## 4 NLA06608-0003 Wilderness Lake        1 PROB_Lake       CPL  5.701737
## 5 NLA06608-0003 Wilderness Lake        2 PROB_Lake       CPL  5.701737
## 6 NLA06608-0004 Puett Reservoir        1 PROB_Lake       WMT 65.386309
##   MaxDepth
## 1      8.3
## 2      2.3
## 3      1.3
## 4      2.5
## 5      2.4
## 6      6.3
```

We can identify distinct values and get those rows


```r
sites_sel %>% distinct(WSA_ECO9)
```

```
##         SITE_ID               LAKENAME VISIT_NO SITE_TYPE WSA_ECO9
## 1 NLA06608-0001          Lake Wurdeman        1 PROB_Lake      WMT
## 2 NLA06608-0002             Crane Pond        1 PROB_Lake      CPL
## 3 NLA06608-0006       Morris Reservoir        1 PROB_Lake      NAP
## 4 NLA06608-0007            Spring Lake        1 PROB_Lake      UMW
## 5 NLA06608-0008           Lake Ahquabi        1 PROB_Lake      TPL
## 6 NLA06608-0012           Cushing Lake        1 PROB_Lake      SPL
## 7 NLA06608-0015      Caballo Reservoir        1 PROB_Lake      XER
## 8 NLA06608-0019            Doyles Lake        1 PROB_Lake      NPL
## 9 NLA06608-0025 Kings Mountian #1 Lake        1 PROB_Lake      SAP
##     AREA_HA DEPTHMAX
## 1  66.29306      8.3
## 2  14.43800      2.3
## 3  56.19975     25.3
## 4  25.47476     19.2
## 5  48.73704      5.5
## 6 177.65751      3.5
## 7 173.99298      7.0
## 8 103.31353      1.2
## 9  11.48124      8.0
```

```r
# Returns the first row with the distinct value so order has an impact
sites_sel %>% arrange(desc(DEPTHMAX)) %>% distinct(WSA_ECO9)
```

```
##         SITE_ID              LAKENAME VISIT_NO SITE_TYPE WSA_ECO9
## 1 NLA06608-0433        Lake Champlain        1 PROB_Lake      NAP
## 2 NLA06608-0129           Ashley Lake        1 PROB_Lake      WMT
## 3 NLA06608-1717          Lake Mcclure        1 PROB_Lake      XER
## 4 NLA06608-1354          Bighorn Lake        1 PROB_Lake      NPL
## 5 NLA06608-0203 Lewis Smith Reservoir        1 PROB_Lake      SAP
## 6 NLA06608-0291            Green Lake        1 PROB_Lake      TPL
## 7 NLA06608-0403             Cass Lake        1 PROB_Lake      UMW
## 8 NLA06608-1300          Conchas Lake        1 PROB_Lake      SPL
## 9 NLA06608-3083  Livingston Reservoir        1 PROB_Lake      CPL
##       AREA_HA DEPTHMAX
## 1 107359.9005     97.0
## 2   1138.9741     60.3
## 3   2267.0704     51.0
## 4   5253.9043     50.2
## 5    471.9935     49.0
## 6   3104.8680     49.0
## 7   6605.1341     34.1
## 8   3550.8681     30.0
## 9  33757.3916     20.0
```

Sampling by number or fraction and with or without replacment is done like:


```r
set.seed(72)
# By Number
sites_sel %>% sample_n(10)
```

```
##                   SITE_ID          LAKENAME VISIT_NO SITE_TYPE WSA_ECO9
## 1146 NLA06608-ELS:2B2-008         Hall Lake        1  REF_Lake      UMW
## 1027        NLA06608-2426         Lost Lake        1 PROB_Lake      NPL
## 1097        NLA06608-3313  Foster Reservoir        1 PROB_Lake      XER
## 1092        NLA06608-3160     Wildwood Lake        1 PROB_Lake      TPL
## 642         NLA06608-1060                          2 PROB_Lake      TPL
## 992         NLA06608-2114       Lake Louise        1 PROB_Lake      SAP
## 1059        NLA06608-2726   South Twin Lake        1 PROB_Lake      WMT
## 845         NLA06608-1532       Storey Lake        1 PROB_Lake      TPL
## 918         NLA06608-1781 Nicasio Reservoir        1 PROB_Lake      XER
## 789         NLA06608-1383       Norway Lake        1 PROB_Lake      UMW
##         AREA_HA DEPTHMAX
## 1146   6.232827     14.0
## 1027  68.184767      1.4
## 1097  52.321948      4.0
## 1092  29.223382      6.6
## 642    5.154350      1.8
## 992   12.752628      6.1
## 1059  40.866979     15.2
## 845   42.644017      9.8
## 918  335.341763     15.5
## 789  907.046212      9.5
```

```r
# By Fraction
sites_sel %>% sample_frac(0.01)
```

```
##            SITE_ID                      LAKENAME VISIT_NO SITE_TYPE
## 783  NLA06608-1370                  Wyckoff Lake        1 PROB_Lake
## 956  NLA06608-1910                      Blomgren        1 PROB_Lake
## 733  NLA06608-1268                 Hawthorn Lake        1 PROB_Lake
## 215  NLA06608-0237         Dacey Reservoir Lower        1 PROB_Lake
## 1130 NLA06608-4949              Newt Graham Lake        1 PROB_Lake
## 1094 NLA06608-3228        Lake Fort Phantom Hill        1 PROB_Lake
## 345  NLA06608-0488                Bee Creek Lake        1 PROB_Lake
## 667  NLA06608-1125              Wononpakook Lake        1 PROB_Lake
## 366  NLA06608-0526                 Becoosin Lake        1 PROB_Lake
## 557  NLA06608-0893                Leesville Lake        1 PROB_Lake
## 754  NLA06608-1323                   Jordan Lake        1 PROB_Lake
## 520  NLA06608-0831          Table Rock Reservoir        1 PROB_Lake
## 188  NLA06608-0204 Turkey Creek Site 6 Reservoir        1 PROB_Lake
##      WSA_ECO9    AREA_HA DEPTHMAX
## 783       UMW   15.33446      6.0
## 956       UMW   31.72826      1.8
## 733       TPL   50.17101      7.6
## 215       XER   72.28416      2.2
## 1130      TPL  117.00390     11.8
## 1094      SPL 1008.00619     13.5
## 345       SPL   13.48196      3.6
## 667       NAP   68.80831      7.5
## 366       UMW   24.04903      5.5
## 557       SAP  386.27802     10.5
## 754       SAP 2322.22457     21.5
## 520       SAP  183.88490     20.0
## 188       SPL   35.77055      2.6
```

To create new columns


```r
# Add it to the other columns
sites_sel %>% mutate(volume = ((10000 * AREA_HA) * DEPTHMAX)/3) %>% head()
```

```
##         SITE_ID        LAKENAME VISIT_NO SITE_TYPE WSA_ECO9   AREA_HA
## 1 NLA06608-0001   Lake Wurdeman        1 PROB_Lake      WMT 66.293055
## 2 NLA06608-0002      Crane Pond        1 PROB_Lake      CPL 14.437998
## 3 NLA06608-0002      Crane Pond        2 PROB_Lake      CPL 14.437998
## 4 NLA06608-0003 Wilderness Lake        1 PROB_Lake      CPL  5.701737
## 5 NLA06608-0003 Wilderness Lake        2 PROB_Lake      CPL  5.701737
## 6 NLA06608-0004 Puett Reservoir        1 PROB_Lake      WMT 65.386309
##   DEPTHMAX     volume
## 1      8.3 1834107.87
## 2      2.3  110691.32
## 3      1.3   62564.66
## 4      2.5   47514.47
## 5      2.4   45613.89
## 6      6.3 1373112.49
```

```r
# Create only the new column
sites_sel %>% transmute(mean_depth = (((10000 * AREA_HA) * DEPTHMAX)/3)/(AREA_HA * 
    10000)) %>% head()
```

```
##   mean_depth
## 1  2.7666667
## 2  0.7666667
## 3  0.4333333
## 4  0.8333333
## 5  0.8000000
## 6  2.1000000
```

Lastly, we can get summaries of our data


```r
sites_sel %>% summarize(avg_depth = mean(DEPTHMAX, na.rm = T), n = n()) %>% 
    head()
```

```
##   avg_depth    n
## 1  9.531095 1252
```

## Manipulating grouped data
If `dplyr` stopped there it would still be a useful package.  It, of course, does not stop there.  One of the more powerful things you can do with `dplyr` is to run grouped operations.  This is especially useful in the context of summarizing your data.  The functions we will be looking at are:

- `group_by()`: Function to create groups from column(s) in your data. 
- `summarise()`: Saw this above, but really shines when summarizing across groups. 
- `n()`: A function for use within the `summarize()` function 


To start working with grouped data you need to do


```r
sites_sel %>% group_by(WSA_ECO9)
```

```
## Source: local data frame [1,252 x 7]
## Groups: WSA_ECO9
## 
##          SITE_ID         LAKENAME VISIT_NO SITE_TYPE WSA_ECO9   AREA_HA
## 1  NLA06608-0001    Lake Wurdeman        1 PROB_Lake      WMT 66.293055
## 2  NLA06608-0002       Crane Pond        1 PROB_Lake      CPL 14.437998
## 3  NLA06608-0002       Crane Pond        2 PROB_Lake      CPL 14.437998
## 4  NLA06608-0003  Wilderness Lake        1 PROB_Lake      CPL  5.701737
## 5  NLA06608-0003  Wilderness Lake        2 PROB_Lake      CPL  5.701737
## 6  NLA06608-0004  Puett Reservoir        1 PROB_Lake      WMT 65.386309
## 7  NLA06608-0004  Puett Reservoir        2 PROB_Lake      WMT 65.386309
## 8  NLA06608-0005     Perkins Lake        1 PROB_Lake      WMT 19.487613
## 9  NLA06608-0005     Perkins Lake        2 PROB_Lake      WMT 19.487613
## 10 NLA06608-0006 Morris Reservoir        1 PROB_Lake      NAP 56.199748
## ..           ...              ...      ...       ...      ...       ...
## Variables not shown: DEPTHMAX (dbl)
```

So, that looks a little different that we were expecting.  What `group_by()` did was to create a special `dplyr` object.  We can see that in how this printed to the screen.  It also includes what groups we are using in this summary.  

Now to work with those groups using `summarise()`


```r
sites_sel %>% group_by(WSA_ECO9) %>% summarize(avg = mean(DEPTHMAX, na.rm = T), 
    std_dev = sd(DEPTHMAX, na.rm = T), n = n())
```

```
## Source: local data frame [9 x 4]
## 
##   WSA_ECO9       avg   std_dev   n
## 1      CPL  4.275969  3.644019 130
## 2      NAP 12.148092 13.702994 131
## 3      NPL  5.376000  8.597514  75
## 4      SAP 10.809028  9.784024 144
## 5      SPL  6.381290  5.459042 155
## 6      TPL  6.211834  5.684888 169
## 7      UMW 10.204046  7.130465 173
## 8      WMT 17.076374 14.789396 182
## 9      XER  9.769892 10.374465  93
```

Pretty cool!  

## Database functionality: joins
So far we have only worked with a single table.  That isn't always what you want to do and `dplyr` provides functions for doing most types of database joins as well as selections based on set operations.  We will be showing ony the basic join types here:  

- `left_join()`: Joins two data frames together based on a common ID. Keeps all observations from the first data frame (i.e. the one on the left) 
- `right_join()`: Same as `left_join()` except it keeps observations from the second data frame 
- `inner_join()`: Keeps only observations that are in both data frames. 
- `full_join()`: Keeps all observations.

Will let you explore the others on your own.

- `semi_join()` 
- `anti_join()` 
- `intersect()` 
- `union()` 
- `setdiff()`

We will need to add another dataset and filter our sites some to show how the different joins work.  


```r
wq <- read.csv("http://www.epa.gov/sites/production/files/2014-10/nla2007_chemical_conditionestimates_20091123.csv")
wq_sel <- wq %>% select(SITE_ID, VISIT_NO, CHLA, NTL, PTL, TURB)
head(wq_sel)
```

```
##         SITE_ID VISIT_NO  CHLA NTL PTL  TURB
## 1 NLA06608-0001        1  0.24 151   6 0.474
## 2 NLA06608-0002        1  3.84 695  36 3.550
## 3 NLA06608-0002        2 20.88 469  22 3.870
## 4 NLA06608-0003        1 16.96 738  43 7.670
## 5 NLA06608-0003        2 12.86 843  50 9.530
## 6 NLA06608-0004        1  4.60 344  18 3.810
```

```r
sites_sel <- sites_sel %>% filter(SITE_TYPE == "PROB_Lake")
```

We can take a look at the dimension of each of these.


```r
dim(sites_sel)
```

```
## [1] 1128    7
```

```r
dim(wq_sel)
```

```
## [1] 1252    6
```

Now lets join the water quality data to the site data and keep only those observations that are in the site data (i.e. only the PROB_Lakes).


```r
sites_wq <- left_join(sites_sel, wq_sel)
```

```
## Joining by: c("SITE_ID", "VISIT_NO")
```

```r
dim(sites_wq)
```

```
## [1] 1128   11
```

```r
head(sites_wq)
```

```
##         SITE_ID        LAKENAME VISIT_NO SITE_TYPE WSA_ECO9   AREA_HA
## 1 NLA06608-0001   Lake Wurdeman        1 PROB_Lake      WMT 66.293055
## 2 NLA06608-0002      Crane Pond        1 PROB_Lake      CPL 14.437998
## 3 NLA06608-0002      Crane Pond        2 PROB_Lake      CPL 14.437998
## 4 NLA06608-0003 Wilderness Lake        1 PROB_Lake      CPL  5.701737
## 5 NLA06608-0003 Wilderness Lake        2 PROB_Lake      CPL  5.701737
## 6 NLA06608-0004 Puett Reservoir        1 PROB_Lake      WMT 65.386309
##   DEPTHMAX  CHLA NTL PTL  TURB
## 1      8.3  0.24 151   6 0.474
## 2      2.3  3.84 695  36 3.550
## 3      1.3 20.88 469  22 3.870
## 4      2.5 16.96 738  43 7.670
## 5      2.4 12.86 843  50 9.530
## 6      6.3  4.60 344  18 3.810
```

Or if we go the other way


```r
wq_sites <- right_join(sites_sel, wq_sel)
```

```
## Joining by: c("SITE_ID", "VISIT_NO")
```

```r
dim(wq_sites)
```

```
## [1] 1252   11
```

```r
head(wq_sites)
```

```
##         SITE_ID        LAKENAME VISIT_NO SITE_TYPE WSA_ECO9   AREA_HA
## 1 NLA06608-0001   Lake Wurdeman        1 PROB_Lake      WMT 66.293055
## 2 NLA06608-0002      Crane Pond        1 PROB_Lake      CPL 14.437998
## 3 NLA06608-0002      Crane Pond        2 PROB_Lake      CPL 14.437998
## 4 NLA06608-0003 Wilderness Lake        1 PROB_Lake      CPL  5.701737
## 5 NLA06608-0003 Wilderness Lake        2 PROB_Lake      CPL  5.701737
## 6 NLA06608-0004 Puett Reservoir        1 PROB_Lake      WMT 65.386309
##   DEPTHMAX  CHLA NTL PTL  TURB
## 1      8.3  0.24 151   6 0.474
## 2      2.3  3.84 695  36 3.550
## 3      1.3 20.88 469  22 3.870
## 4      2.5 16.96 738  43 7.670
## 5      2.4 12.86 843  50 9.530
## 6      6.3  4.60 344  18 3.810
```

To get just those observations that are common to both


```r
# First manufacture some differences
wq_samp <- wq_sel %>% sample_frac(0.75)
sites_samp <- sites_sel %>% sample_frac(0.75)
dim(wq_samp)
```

```
## [1] 939   6
```

```r
dim(sites_samp)
```

```
## [1] 846   7
```

```r
# Then the inner_join
sites_wq_in <- inner_join(sites_samp, wq_samp)
```

```
## Joining by: c("SITE_ID", "VISIT_NO")
```

```r
dim(sites_wq_in)
```

```
## [1] 623  11
```

```r
head(sites_wq_in)
```

```
##         SITE_ID      LAKENAME VISIT_NO SITE_TYPE WSA_ECO9    AREA_HA
## 1 NLA06608-4643    Birch Lake        1 PROB_Lake      SPL  449.46901
## 2 NLA06608-0738   Island Pond        1 PROB_Lake      NAP   76.92370
## 3 NLA06608-0900   Forbes Lake        1 PROB_Lake      TPL  233.88423
## 4 NLA06608-1148   Mother Lake        1 PROB_Lake      SPL  201.95267
## 5 NLA06608-0031 Caldwell Lake        2 PROB_Lake      SAP   24.24954
## 6 NLA06608-0938 Muskegon Lake        1 PROB_Lake      UMW 1899.63347
##   DEPTHMAX  CHLA  NTL PTL    TURB
## 1      8.8 13.83  557  19   4.670
## 2     14.0  1.70  223   3   0.539
## 3      8.2 15.65  700  48   3.910
## 4      1.4 48.00 6934 242 172.000
## 5      4.8  8.50  394  24   6.240
## 6     19.0 11.89  519  34   5.410
```

Lastly, lets join and keep it all


```r
sites_wq_all <- full_join(sites_sel, wq_sel)
```

```
## Joining by: c("SITE_ID", "VISIT_NO")
```

```r
dim(sites_wq_all)
```

```
## [1] 1252   11
```

```r
head(sites_wq_all)
```

```
##         SITE_ID        LAKENAME VISIT_NO SITE_TYPE WSA_ECO9   AREA_HA
## 1 NLA06608-0001   Lake Wurdeman        1 PROB_Lake      WMT 66.293055
## 2 NLA06608-0002      Crane Pond        1 PROB_Lake      CPL 14.437998
## 3 NLA06608-0002      Crane Pond        2 PROB_Lake      CPL 14.437998
## 4 NLA06608-0003 Wilderness Lake        1 PROB_Lake      CPL  5.701737
## 5 NLA06608-0003 Wilderness Lake        2 PROB_Lake      CPL  5.701737
## 6 NLA06608-0004 Puett Reservoir        1 PROB_Lake      WMT 65.386309
##   DEPTHMAX  CHLA NTL PTL  TURB
## 1      8.3  0.24 151   6 0.474
## 2      2.3  3.84 695  36 3.550
## 3      1.3 20.88 469  22 3.870
## 4      2.5 16.96 738  43 7.670
## 5      2.4 12.86 843  50 9.530
## 6      6.3  4.60 344  18 3.810
```

## Database functionality: external databases

- `src_sqlite()` 
- `tbl()` 
- `collect()` 
- `translate_sql()`
- `copy_to()`

