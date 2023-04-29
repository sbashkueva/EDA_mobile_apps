# The Android App Market on Google Play

## Data description

Link to the Kaggle dataset: https://www.kaggle.com/datasets/lava18/google-play-store-apps?select=googleplaystore.csv

The dataset for this project was found on Kaggle and provides information about Android applications on Google Play. 
We will compare around ten thousand apps on Google Play across different categories to get a comprehensive data analysis of Android app market. 
We’ll look for insights in the data to understand popularity, pricing models, reviews for different app groups.

It consists of two files:
1. 'googleplaystore.csv' - apps
2. 'googleplaystore_user_reviews.csv' - reviews

The apps table contains all the details of the applications on Google Play:
 
* App - Application name
* Category - Category the app belongs to
* Rating - Overall user rating of the app (as when scraped)
* Reviews - Number of user reviews for the app (as when scraped)
* Size - Size of the app (as when scraped)
* Installs - Number of user downloads/installs for the app (as when scraped)
* Type - Paid or Free
* Price - Price of the app in USD (as when scraped)
* Content Rating - Age group the app is targeted at
* Genres - An app can belong to multiple genres (apart from its main category). For eg, a musical family game will belong to

The reviews table collects the first 'most helpful' 100 reviews for each app. 
The text in each review has been preprocessed and attributed with three new features: Sentiment (Positive, Negative or Neutral), Sentiment Polarity and Sentiment Subjectivity. 
Sentiment Polarity is a variable for an app review ranging from -1 (strongly negative) to 1 (strongly positive).

* App - Application name
* Translated_Review - User review (Preprocessed and translated to English)
* Sentiment - Positive/Negative/Neutral (Preprocessed)
* Sentiment_Polarity - Sentiment polarity score
* Sentiment_Subjectivity - Sentiment subjectivity score


## Questions to be explored

The data provided can help to receive answers for the following questions:
1. What kind of apps categories are the most popular in the market?
2. For what kind of apps users tend to pay more across categories?
3. Do more expensive apps tend to receive higher rating?
4. Does the number of reviews affect the number of installs and its ratings?
5. What kind of apps receive more positive and negative reviews?


## Used libraries
* pandas
* numpy
* sqlite3
* matplotlib.pyplot
* seaborn
* plotly.express
