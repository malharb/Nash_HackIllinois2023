
![alt text](/My project-1(1).png)

Inspiration

Schizophrenia is a psychotic disorder characterized by symptoms of delusions, hallucinations, disorganized thinking and extreme agitation. As per the World Health Organization (WHO), [schizophrenia affects approximately 24 million people or 1 in 300 people worldwide](https://www.who.int/news-room/fact-sheets/detail/schizophrenia). However, [epidemiologists estimate that around one-third of schizophrenia cases go undiagnosed.](https://www.clinicaltrialsarena.com/comment/schizophrenia-cases-undiagnosed/). A reason for this is that physicians often misdiagnose schizophrenia for other conditions that have similar symptoms. [Even though the disorder has been studied for more than a 100 years, researchers still haven't been able to identify a precise cause of schizophrenia](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4159061/).

Our inspiration for this project was to help investigate and provide an alternative method of detecting schizophrenic behavior. Indications of symptoms such as delusions, disorganized thinking and extreme agitation are bound to be reflected in the motor activity of schizophrenic patients. [In fact, people with schizophrenia are linked with repetitious and rigid behavior patterns as compared to healthy controls](https://pubmed.ncbi.nlm.nih.gov/30888511/).

 [Additionally, many people are unable to afford mental health support.](https://www.npr.org/sections/health-shots/2021/08/23/1030430464/mental-health-parity-therapy-high-cost) The potential link between motor activity and schizophrenia, and the existing economic barrier to accessing mental health support, inspired us to create NASH, a free iOS app that pulls in motor activity data over a 12 hour period and detects if it is indicative of schizophrenic behavior using a Long Short-Term Memory (LSTM) neural network.
 
 
What it does

NASH is a free, easy-to-use iOS app (with a companion WatchOS app) that pulls in motor activity data over a 12 hour (3 PM - 3 AM) period in order to detect if a person is exhibiting schizophrenic behavior. It uses a Long Short-Term Memory (LSTM) neural network. The LSTM network detects patterns in the sequential, 12-hour data, on a minute-by-minute basis. The companion WatchOS app's GUI is very user-friendly and it features only one button, at the click of which it sends activity data from the most recently completed 3 PM - 3 AM cycle, to the iOS app. If there is insufficient data for those 12 hours, which could be the case due to events such as the Apple Watch losing power in the middle, the companion app automatically sends 12 hours of data for the interval between 3 PM and 3 AM from the previous day. After valid data is pulled in by the iOS app, it feeds it to the LSTM network that is loaded into the model to make a classification of the behavior as schizophrenic or not. 

LSTMs are a kind of a Recurrent Neural Network (RNN) that are capable of recognizing patterns in long-term sequential data. The network is a chain of cells and each cell has a state that is regulated by various gates. [They were founded by Sepp Hochreiter and Jurgen Schmidhuber](http://www.bioinf.jku.at/publications/older/2604.pdf).


How we built it

We used the [PSYKOSE dataset](https://datasets.simula.no/psykose/) to train our neural network. The dataset contained 22 schizophrenic patients and 32 healthy controls, and multiple days of activity count for each person were recorded. We split each day into two segments of 12 hours, and since we had readings for each minute, we had 720 readings for each segment and 1440 readings for each day. In the process of reading in the data in this form, we also normalized the data for each 12 hour segment by dividing all activity count recordings by the highest activity count in that segment and multiplying it by 1000 (we multiplied it by a 1000 so that the data values wouldn't be too small, affecting the gradient). Our rationale for doing this was that firstly, we wanted to train our model to detect patterns in relative activity throughout the 12-hour period as opposed to the actual activity count value. While analyzing and visualizing our data we found that for many control participants and schizophrenic patients, the range of the activity counts was very similar (see Figure 1), and so the actual standalone values are probably not indicative of schizophrenic behavior. Additionally, we also normalized it due to the lack of transparency around the algorithm used to calculate activity count. The data in the PSYKOSE dataset was collected using an Actigraph 4 which collects gravitational acceleration units greater than 0.05 g in the x, y and z coordinates and then calculates the activity count using a proprietary algorithm we did not have access to. We reasoned that normalized data adequately conveys the magnitude of the activity while allowing the model to gauge the patterns in the activity data. By training the model on normalized data, we are able to use the model to make classification predictions using similarly normalized Apple Watch data. 

After the reading-in, parsing and appropriate preprocessing of the data, our data was formatted into a three-dimensional NumPy array of the dimensions [2020, 720, 1]. We used TensorFlow 2.0 to build the neural network and TensorFlow requires input into an LSTM to be in the form of a three dimensional array. Our neural network is a sequential model and the architecture is as follows: an LSTM layer of 75 units, a Dropout layer with a 25% rate to help prevent overfitting, a Densely-connected ReLu layer of 100 units, a Densely-connected ReLu layer of 25 units, and finally a Sigmoid output layer. We used binary cross-entropy for the loss function and the Adam optimizer. After training the model we converted it into a CoreML model so that it can be run locally in the iOS app. For an overview of the training process and of the overall architecture, refer to Figure 2. 

An overview of the WatchOS and iOS architecture is that the companion WatchOS app sends the gravitational acceleration units in the x, y and z coordinates calculated at 50 Hz for the 12 hour time period (see the What it does section) to the iOS app at the click of a button. The iOS app then calculates the magnitude of the acceleration and checks if the value exceeds the threshold value of 0.05 g. If the value is smaller than the threshold value, it assigns a value of 0 to that instance. It groups together readings by the minute and for each minute's worth of readings, it finds the maximum magnitude of acceleration and it scales that in the same way that the activity counts in the training data were scaled. Then it feeds this scaled data into the CoreML model, which outputs a classification prediction. For an overview of the WatchOS and iOS architecture, refer to Figure 3.


Challenges we ran into

The first challenge we ran into was that we didn't have as much data to train and test our model. While we firmly believe that we were able to make a fairly accurate model with the amount of data we were provided, we would have liked to have more data to train our model and to evaluate our model. We would also have liked more variety in the dataset. For example, all of the patients were from the Haukeland University hospital, and this could have caused some bias in our model. 

The next challenge we ran into was not having access to Actiwatch 4's algorithm to calculate activity counts. Having access to their algorithm could have helped us improve our preprocessing. We tried to use [this research paper](https://www.nature.com/articles/s41598-022-16003-x) to gain some insight on the algorithm. The paper also outlines how lack of transparency has hindered comparability between studies. 

The final challenge we ran into was trying to navigate the documentation of WatchOS after the release of WatchOS 7 given that the documentation was not separated and the two different user-interface kits are not compatible with each other. 


Accomplishments that we're proud of

We're proud that our model had a 72% accuracy despite having limited data points to train on. 

We're proud that we were able to create a fully functioning iOS app with a companion WatchOS app, both of which perform all the functions we envisioned. 


What we learned

We learned how to create and use LSTM models. Additionally, we learned how to create WatchOS apps and how to use Watch Connectivity to establish communication between Watch OS and iOS. We also learned how to use CoreMotion and CoreML to create machine learning models that can be deployed on Apple products. 

Beyond specific technology, we learned how to read and extract information from research papers, read documentation and how to work with unfamiliar frameworks.


What's next for NASH

Ideally, we would like to work with the Simula Research Laboratory to collect more data to further train our model and to be able to accurately test and evaluate the performance of our model. Then, we would like to investigate the relationship between motor activity and other mental disorders such as depression. 
