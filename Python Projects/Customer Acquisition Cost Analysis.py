import pandas as pd
import plotly.express as px
import plotly.io as pio
import plotly.graph_objects as go
pio.templates.default = "plotly_white"

#Import Dataset
data = pd.read_csv("D:/Downloads/customer_acquisition_cost_dataset.csv")
print(data.head())

data.info()

#Calculate the customer acquisition cost
data['CAC'] = data['Marketing_Spend'] / data['New_Customers']

fig1 = px.bar(data, x='Marketing_Channel',
              y='CAC', title='CAC by Marketing Channel')
fig1.show()


#relationship between new customers acquired and CAC
fig1 = px.bar(data, x='Marketing_Channel',
              y='CAC', title='CAC by Marketing Channel')
fig1.show()


#summary statistics
summary_stats = data.groupby('Marketing_Channel')['CAC'].describe()
print(summary_stats)

#Calculate the coversion ratio
data['Conversion_Rate'] = data['New_Customers'] / data['Marketing_Spend'] * 100

# Conversion Rates by Marketing Channel
fig = px.bar(data, x='Marketing_Channel',
             y='Conversion_Rate',
             title='Conversion Rates by Marketing Channel')
fig.show()

#Find break-even point
data['Break_Even_Customers'] = data['Marketing_Spend'] / data['CAC']

fig = px.bar(data, x='Marketing_Channel',
             y='Break_Even_Customers',
             title='Break-Even Customers by Marketing Channel')
fig.show()

fig = go.Figure()

# Actual Customers Acquired
fig.add_trace(go.Bar(x=data['Marketing_Channel'], y=data['New_Customers'],
                     name='Actual Customers Acquired', marker_color='royalblue'))

# Break-Even Customers
fig.add_trace(go.Bar(x=data['Marketing_Channel'], y=data['Break_Even_Customers'],
                     name='Break-Even Customers', marker_color='lightcoral'))

# Update the layout
fig.update_layout(barmode='group', title='Actual vs. Break-Even Customers by Marketing Channel',
                  xaxis_title='Marketing Channel', yaxis_title='Number of Customers')

# Show the chart
fig.show()