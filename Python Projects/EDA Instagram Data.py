import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import plotly.io as pio
pio.templates.default = "plotly_white"

data = pd.read_csv("D:/Downloads/Instagram data.csv", encoding='latin-1')
print(data.head())

print(data.columns)

print(data.info())

print(data.describe())

#Check Null
print(data.isnull().sum())

#histogram
fig = px.histogram(data,
                   x='Impressions',
                   nbins=10,
                   title='Distribution of Impressions')
fig.show()

#number of impression per post
fig = px.line(data, x= data.index,
              y='Impressions',
              title='Impressions Over Time')
fig.show()

#Validating metrics
fig = go.Figure()

fig.add_trace(go.Scatter(x=data.index, y=data['Likes'], name='Likes'))
fig.add_trace(go.Scatter(x=data.index, y=data['Saves'], name='Saves'))
fig.add_trace(go.Scatter(x=data.index, y=data['Follows'], name='Follows'))

fig.update_layout(title='Metrics Over Time',
                  xaxis_title='Date',
                  yaxis_title='Count')

fig.show()

#Distribution of reach from different sources
reach_sources = ['From Home', 'From Hashtags', 'From Explore', 'From Other']
reach_counts = [data[source].sum() for source in reach_sources]

colors = ['#FFB6C1', '#87CEFA', '#90EE90', '#FFDAB9']

fig = px.pie(data_frame=data, names=reach_sources,
             values=reach_counts,
             title='Reach from Different Sources',
             color_discrete_sequence=colors)
fig.show()

#Distribution of engagement sources
engagement_metrics = ['Saves', 'Comments', 'Shares', 'Likes']
engagement_counts = [data[metric].sum() for metric in engagement_metrics]

colors = ['#FFB6C1', '#87CEFA', '#90EE90', '#FFDAB9']

fig = px.pie(data_frame=data, names=engagement_metrics,
             values=engagement_counts,
             title='Engagement Sources',
             color_discrete_sequence=colors)
fig.show()

#Relationship between the number of profile visits
fig = px.scatter(data,
                 x='Profile Visits',
                 y='Follows',
                 trendline = 'ols',
                 title='Profile Visits vs. Follows')
fig.show()

#type of hashtags word cloud
from wordcloud import WordCloud

hashtags = ' '.join(data['Hashtags'].astype(str))
wordcloud = WordCloud().generate(hashtags)

fig = px.imshow(wordcloud, title='Hashtags Word Cloud')
fig.show()


# Create a list to store all hashtags
all_hashtags = []

# Iterate through each row in the 'Hashtags' column
for row in data['Hashtags']:
    hashtags = str(row).split()
    hashtags = [tag.strip() for tag in hashtags]
    all_hashtags.extend(hashtags)

# Create a pandas DataFrame to store the hashtag distribution
hashtag_distribution = pd.Series(all_hashtags).value_counts().reset_index()
hashtag_distribution.columns = ['Hashtag', 'Count']

fig = px.bar(hashtag_distribution, x='Hashtag',
             y='Count', title='Distribution of Hashtags')
fig.show()

# Create a dictionary to store the likes and impressions for each hashtag
hashtag_likes = {}
hashtag_impressions = {}

# Iterate through each row in the dataset
for index, row in data.iterrows():
    hashtags = str(row['Hashtags']).split()
    for hashtag in hashtags:
        hashtag = hashtag.strip()
        if hashtag not in hashtag_likes:
            hashtag_likes[hashtag] = 0
            hashtag_impressions[hashtag] = 0
        hashtag_likes[hashtag] += row['Likes']
        hashtag_impressions[hashtag] += row['Impressions']

# Create a DataFrame for likes distribution
likes_distribution = pd.DataFrame(list(hashtag_likes.items()), columns=['Hashtag', 'Likes'])

# Create a DataFrame for impressions distribution
impressions_distribution = pd.DataFrame(list(hashtag_impressions.items()), columns=['Hashtag', 'Impressions'])

fig_likes = px.bar(likes_distribution, x='Hashtag', y='Likes',
                   title='Likes Distribution for Each Hashtag')

fig_impressions = px.bar(impressions_distribution, x='Hashtag',
                         y='Impressions',
                         title='Impressions Distribution for Each Hashtag')

fig_likes.show()
fig_impressions.show()