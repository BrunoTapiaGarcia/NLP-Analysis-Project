#installing and loading the mongolite library to download the Airbnb data
install.packages("mongolite") #need to run this line of code only once and then you can comment out
install.packages("tidytext")
library(mongolite)
library(topicmodels)

# This is the connection_string. You can get the exact url from your MongoDB cluster screen
#replace the <<user>> with your Mongo user name and <<password>> with the mongo password
#lastly, replace the <<server_name>> with your MongoDB server name
connection_string <- 'mongodb+srv://brunotg10:mongo123@cluster0.occmd.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0' 
airbnb_collection <- mongo(collection="listingsAndReviews", db="sample_airbnb", url=connection_string)

#Here's how you can download all the Airbnb data from Mongo
## keep in mind that this is huge and you need a ton of RAM memory
airbnb_all <- airbnb_collection$find()


#1 subsetting your data based on a condition:
mydf <- airbnb_collection$find('{"bedrooms":2, "price":{"$gt":50}}')

#2 writing an analytical query on the data::
mydf_analytical <- airbnb_collection$aggregate('[{"$group":{"_id":"$room_type", "avg_price": {"$avg":"price"}}}]')


# Look at the data
View(airbnb_all)
unique(airbnb_all$property_type)
unique(airbnb_all$room_type)
unique(airbnb_all$bed_type)

#############################
## TOKENIZING SUMMARY DATA ##
#############################

# Change name of summary column to tokenize
colnames(airbnb_all)[3] <- "text"

# Tokenize the text in the "summary" column and create a new column "word"
library(tidyr)
library(tidytext)
library(dplyr)

# Remove stopwords
airbnb_nostop <- airbnb_all %>%
  unnest_tokens(word, text) %>%
  filter(!word %in% custom_stopwords) %>%
  count(word, sort=TRUE)

# Adding more words to the stopwords list
custom_stopwords <- c("de", "es", "en", "la", "el", "y", "et", "pour", "une", "du", stop_words$word)

# visualizing the most common words
airbnb_nostop %>%
  filter(n > 1000) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(x = word, y = n, fill = n)) + 
  geom_col(show.legend = FALSE) +
  scale_fill_gradient(low = "lightblue", high = "blue") +
  coord_flip() +
  labs(title = "Word Frequency After Removing Stopwords",
       x = "Words",
       y = "Frequency") +
  theme_minimal(base_size = 15) +
  theme(plot.title = element_text(hjust = 0.5))

###################################
## N-grams for description column##
###################################

# Restoring the initial dataset
airbnb_all <- airbnb_collection$find()

# Change name of summary column to tokenize
colnames(airbnb_all)[5] <- "text"

airbnb_trigram <- airbnb_all %>%
  unnest_tokens(trigram, text, token = "ngrams", n=3) %>%
  count(trigram, sort=TRUE)

airbnb_trigram #To see the trigrams in the description column

# Removing stop words from trigram data, using the separate function:
library(tidyr)
trigram_separated <- airbnb_trigram %>%
  separate(trigram, c("word1", "word2", "word3"), sep = " ")

trigram_filtered <- trigram_separated %>%
  filter(!word1 %in% stop_words$word) %>%
  filter(!word2 %in% stop_words$word) %>%
  filter(!word3 %in% stop_words$word)  

#creating a new trigram with "no-stop-words":
trigram_counts <- trigram_filtered 

# checking the results
trigram_counts

# Visualizing the results
library(ggplot2)

# Creating a dataframe to plot the results
trigram_data <- data.frame(
  word1 = c("queen", "rio", "flat", "5", "king", "5", "free", "queen", "tsim", "cama"),
  word2 = c("size", "de", "screen", "minute", "size", "minutes", "wi", "sized", "sha", "de"),
  word3 = c("bed", "janeiro", "tv", "walk", "bed", "walk", "fi", "bed", "tsui", "casal"),
  n = c(245, 185, 152, 116, 113, 112, 110, 102, 95, 92)
)

# Joining the data
trigram_data$trigram <- paste(trigram_data$word1, trigram_data$word2, trigram_data$word3, sep = " ")


# Order by frequency
trigram_data <- trigram_data[order(-trigram_data$n), ]

# showing the graph
ggplot(head(trigram_data, 10), aes(x = reorder(trigram, n), y = n)) +
  geom_col(fill = "skyblue") +
  coord_flip() +
  labs(title = "Top 10 Trigrams", x = "Trigram", y = "Frequency") +
  theme_minimal()


##########################################
# Filtering the 3 most popular countries #
##########################################
# Restoring the initial dataset
airbnb_all <- airbnb_collection$find()

library(dplyr)

# Get countries using case_when
airbnb_all <- airbnb_all %>%
  mutate(country = case_when(
    grepl("united states|usa", tolower(host$host_location)) ~ "United States",
    grepl("spain", tolower(host$host_location)) ~ "Spain",
    grepl("brazil", tolower(host$host_location)) ~ "Brazil",
    grepl("australia", tolower(host$host_location)) ~ "Australia",
    grepl("hong kong", tolower(host$host_location)) ~ "Hong Kong",
    grepl("portugal", tolower(host$host_location)) ~ "Portugal",
    grepl("turkey", tolower(host$host_location)) ~ "Turkey",
    grepl("canada", tolower(host$host_location)) ~ "Canada",
    TRUE ~ "Other"
  ))

# Showing the most popular countries
top_countries <- airbnb_all %>%
  group_by(country) %>%
  summarise(count = n()) %>%
  arrange(desc(count))

# Checking results
top_countries

# Converting the most popular countries in dataframe
usa_df <- airbnb_all %>% filter(country == "United States")
canada_df <- airbnb_all %>% filter(country == "Canada")
australia_df <- airbnb_all %>% filter(country == "Australia")



##########################################################
# Comparing description data of 3 most popular countries #
##########################################################

# Converting USA description name into text
colnames(usa_df)[3] <- "text"

# Creating a tidy format for United States listings
library(tidytext)
tidy_usa <- usa_df %>%
  unnest_tokens(word, text) %>%
  anti_join(stop_words) %>%
  count(word, sort = TRUE)

# checking results
print(tidy_usa)

# Converting Canada description name into text
colnames(canada_df)[3] <- "text"

# Creating a tidy format for Canada listings
library(tidytext)
tidy_canada <- canada_df %>%
  unnest_tokens(word, text) %>%
  anti_join(stop_words) %>%
  count(word, sort = TRUE)

# checking results
print(tidy_canada)

# Converting Australia description name into text
colnames(australia_df)[3] <- "text"

# Creating a tidy format for Australia listings
library(tidytext)
tidy_australia <- australia_df %>%
  unnest_tokens(word, text) %>%
  anti_join(stop_words) %>%
  count(word, sort = TRUE)

# checking results
print(tidy_australia)

##########################################
#### Combinig datasets to do frequencies #
##########################################

library(tidyr)
library(stringr)
frequency <- bind_rows(mutate(tidy_usa, author="United States"),
                       mutate(tidy_canada, author= "Canada"),
                       mutate(tidy_australia, author="Australia")
)%>%#closing bind_rows
  mutate(word=str_extract(word, "[a-z']+")) %>%
  count(author, word) %>%
  group_by(author) %>%
  mutate(proportion = n/sum(n))%>%
  select(-n) %>%
  spread(author, proportion) %>%
  gather(author, proportion, `Canada`, `Australia`)
View(frequency)

#let's plot the correlograms:
library(scales)
library(stringr)

ggplot(frequency, aes(x=proportion, y=`United States`, 
                      color = abs(`United States`- proportion)))+
  geom_abline(color="grey40", lty=2)+
  geom_jitter(alpha=.1, size=2.5, width=0.3, height=0.3)+
  geom_text(aes(label=word), check_overlap = TRUE, vjust=1.5) +
  scale_x_log10(labels = percent_format())+
  scale_y_log10(labels= percent_format())+
  scale_color_gradient(limits = c(0,0.001), low = "darkslategray4", high = "gray75")+
  facet_wrap(~author, ncol=2)+
  theme(legend.position = "none")+
  labs(y= "United States", x=NULL)

#####################################
####### TF-IDF framework in Airbnb ##
#####################################
library(dplyr)
library(tidyr)
library(tidytext)
library(ggplot2)

# Tokenize text and count words per country for each dataframe
usa_token <- usa_df %>%
  unnest_tokens(word, text) %>%
  count(country, word, sort=TRUE) %>%
  ungroup()

canada_token <- canada_df %>%
  unnest_tokens(word, text) %>%
  count(country, word, sort=TRUE) %>%
  ungroup()

australia_token <- australia_df %>%
  unnest_tokens(word, text) %>%
  count(country, word, sort=TRUE) %>%
  ungroup()

# Calculate the total number of words per country for each dataframe
total_words_usa <- usa_token %>%
  summarise(total = sum(n))

total_words_canada <- canada_token %>%
  summarise(total = sum(n))

total_words_australia <- australia_token %>%
  summarise(total = sum(n))

# Linking dataframes with word totals by country
usa_words <- bind_cols(usa_token, total_words_usa) %>%
  filter(total > 0)

canada_words <- bind_cols(canada_token, total_words_canada) %>%
  filter(total > 0)

australia_words <- bind_cols(australia_token, total_words_australia) %>%
  filter(total > 0)

# Combine dataframes
airbnb_words <- bind_rows(usa_words, canada_words, australia_words)

# Showing the graph
ggplot(airbnb_words, aes(n/total, fill = country)) +
  geom_histogram(show.legend = FALSE) +
  xlim(NA, 0.001) +
  facet_wrap(~country, ncol = 2, scales = "free_y")


###################################################
################# TF_IDF ##########################
###################################################

## Set the library
library(tidytext)

# Stopwords
data(stop_words)

# Create a list with additional stopwords
custom_stopwords <- data.frame(
  word = c("de", "es", "aquí", "también", "de", "es", "en", "la", "el", "y", "et", "pour", "une", "du","avec"), # Agrega las palabras que desees excluir
  lexicon = "custom"
)

# Combine defined and added stopwords
all_stopwords <- bind_rows(stop_words, custom_stopwords)

# Sort stopwords
airbnb_words <- airbnb_words %>%
  anti_join(all_stopwords)

# Calculate TF-IDF
country_words <- airbnb_words %>%
  bind_tf_idf(word, country, n)

# Sort by tf-idf and visualize 
country_words %>% 
  arrange(desc(tf_idf))

# Create the plots
country_words %>%
  arrange(desc(tf_idf)) %>%
  mutate(word = factor(word, levels = rev(unique(word)))) %>%
  group_by(country) %>%
  top_n(15) %>%
  ungroup %>%
  ggplot(aes(word, tf_idf, fill = country)) +
  geom_col(show.legend = FALSE) +
  labs(x = NULL, y = "tf-idf") +
  facet_wrap(~country, ncol = 2, scales = "free") +
  coord_flip()


############################################################
## N-grams for neigborhood overview comparison by country ##
############################################################

# Restoring each country dataframe and changing column to text
colnames(usa_df)[3] <- "summary"
colnames(usa_df)[6] <- "text"

colnames(canada_df)[3] <- "summary"
colnames(canada_df)[6] <- "text"

colnames(australia_df)[3] <- "summary"
colnames(australia_df)[6] <- "text"

# Defining the trigrams for country 
usa_trigram <- usa_df %>%
  unnest_tokens(trigram, text, token = "ngrams", n=3) %>%
  count(trigram, sort=TRUE)

canada_trigram <- canada_df %>%
  unnest_tokens(trigram, text, token = "ngrams", n=3) %>%
  count(trigram, sort=TRUE)

australia_trigram <- australia_df %>%
  unnest_tokens(trigram, text, token = "ngrams", n=3) %>%
  count(trigram, sort=TRUE)

# Checking results
usa_trigram 
canada_trigram
australia_trigram

# Separating the words
library(tidyr)

trigram_usa_separated <- usa_trigram %>%
  separate(trigram, c("word1", "word2", "word3"), sep = " ")

trigram_can_separated <- canada_trigram %>%
  separate(trigram, c("word1", "word2", "word3"), sep = " ")

trigram_aus_separated <- australia_trigram %>%
  separate(trigram, c("word1", "word2", "word3"), sep = " ")

# Removing stop words from trigram data, using the separate function:
trigram_usa_filtered <- trigram_usa_separated %>%
  filter(!word1 %in% stop_words$word) %>%
  filter(!word2 %in% stop_words$word) %>%
  filter(!word3 %in% stop_words$word)  

trigram_can_filtered <- trigram_can_separated %>%
  filter(!word1 %in% stop_words$word) %>%
  filter(!word2 %in% stop_words$word) %>%
  filter(!word3 %in% stop_words$word)  

trigram_aus_filtered <- trigram_aus_separated %>%
  filter(!word1 %in% stop_words$word) %>%
  filter(!word2 %in% stop_words$word) %>%
  filter(!word3 %in% stop_words$word)  

# checking the results
trigram_usa_filtered
trigram_can_filtered
trigram_aus_filtered


# Filter NA for USA
trigram_usa_filtered <- trigram_usa_filtered %>%
  filter(!is.na(word1) & !is.na(word2) & !is.na(word3))

# Filter NA for Canada
trigram_can_filtered <- trigram_can_filtered %>%
  filter(!is.na(word1) & !is.na(word2) & !is.na(word3))

# Filter NA for Australia
trigram_aus_filtered <- trigram_aus_filtered %>%
  filter(!is.na(word1) & !is.na(word2) & !is.na(word3))

# Creating the visuals
# Wordcloud for USA
wordcloud(words = paste(trigram_usa_filtered$word1, trigram_usa_filtered$word2, trigram_usa_filtered$word3),
          freq = trigram_usa_filtered$n, 
          min.freq = 5, 
          colors = brewer.pal(8, "Dark2"),
          scale = c(3, 0.5),
          random.order = FALSE,
          main = "Trigrams in USA")

# Wordcloud for Canada
wordcloud(words = paste(trigram_can_filtered$word1, trigram_can_filtered$word2, trigram_can_filtered$word3),
          freq = trigram_can_filtered$n, 
          min.freq = 5, 
          colors = brewer.pal(8, "Set1"),
          scale = c(3, 0.5),
          random.order = FALSE,
          main = "Trigrams in Canada")

# Wordcloud for Australia
wordcloud(words = paste(trigram_aus_filtered$word1, trigram_aus_filtered$word2, trigram_aus_filtered$word3),
          freq = trigram_aus_filtered$n, 
          min.freq = 5, 
          colors = brewer.pal(8, "Set3"),
          scale = c(3, 0.5),
          random.order = FALSE,
          main = "Trigrams in Australia")


##############
# Shiny Apps #
##############

library(shiny)
library(ggplot2)
library(plotly)
library(dplyr)
library(tidytext)

# UI for the first app
ui1 <- fluidPage(
  titlePanel("TF-IDF framework in Airbnb"),
  sidebarLayout(
    sidebarPanel(),
    mainPanel(
      plotlyOutput("airbnb_plot")
    )
  )
)

# Server first app
server1 <- function(input, output) {
  output$airbnb_plot <- renderPlotly({
    gg <- ggplot(airbnb_words, aes(n/total, fill = country)) +
      geom_histogram() +
      xlim(NA, 0.001) +
      facet_wrap(~country, ncol = 2, scales = "free_y")
    
    ggplotly(gg)
  })
}

# UI second app
ui2 <- fluidPage(
  titlePanel("TF-IDF Visualization"),
  sidebarLayout(
    sidebarPanel(),
    mainPanel(
      plotlyOutput("tfidf_plot")
    )
  )
)

# Server second app
server2 <- function(input, output) {
  country_words <- airbnb_words %>%
    bind_tf_idf(word, country, n)
  
  output$tfidf_plot <- renderPlotly({
    country_words %>%
      mutate(word = factor(word, levels = rev(unique(word)))) %>%
      group_by(country) %>%
      top_n(15) %>%
      ungroup() %>%
      ggplot(aes(word, tf_idf, fill = country)) +
      geom_col(show.legend = FALSE) +
      labs(x = NULL, y = "TF-IDF") +
      facet_wrap(~ country, ncol = 2, scales = "free") +
      coord_flip() -> tfidf_plot_gg
    
    ggplotly(tfidf_plot_gg)
  })
}

# UI third app
ui3 <- fluidPage(
  titlePanel("Display Trigrams by Country"),
  tabsetPanel(
    tabPanel("United States", dataTableOutput("usa_table")),
    tabPanel("Canada", dataTableOutput("canada_table")),
    tabPanel("Australia", dataTableOutput("australia_table"))
  )
) 

# Server for third app
server3 <- function(input, output) {
  output$usa_table <- renderDataTable({
    trigram_usa_filtered
  })
  
  output$canada_table <- renderDataTable({
    trigram_can_filtered
  })
  
  output$australia_table <- renderDataTable({
    trigram_aus_filtered
  })
}

# Run the Shiny apps
shinyApp(ui = ui1, server = server1)
shinyApp(ui = ui2, server = server2)
shinyApp(ui = ui3, server = server3)



