# AirBnb NLP-Analysis-Project

**Introduction**

This project aims to achieve to perform an unstructured data analysis of the descriptions of the properties listed on the AirBnb platform worldwide, the database was extracted directly from the ModgoDB server and I used techniques such as n-grams analysis and TF-IDF Framework to show the findings. 

Frequency of the most used words in the entire dataset
![Descripción de la imagen](https://drive.google.com/uc?export=view&id=1vaiYtMCAPox0SBsKWCJe04wTi-OE10wW)

Sets of three words (Trigrams) most commonly used throughout the dataset
![Descripción de la imagen](https://drive.google.com/uc?export=view&id=164wHTiqpVINIpCWxNQMdcD5K_Hnw3R9m)

The most used words in the United States, Australia and Canada, the countries containing the most data records in the aggregate
![Descripción de la imagen](https://drive.google.com/uc?export=view&id=1wTUnRTfNbSZpe_MaaqqTtaHPcNKE8VC_)


Distribution of Relative Frequencies of Terms in the different regions
![Descripción de la imagen](https://drive.google.com/uc?export=view&id=1VVTVIe6xvXHwUrSzI_n3J8LN-gM-ziSD)

**TF-IDF Analysis**

Australia
- Keywords such as "cbd" (Central Business District), "Sydney", "Bondi", and "Manly" indicate a strong focus on urban and coastal areas, especially Sydney, which is one of the most popular cities in Australia.
- The emphasis on "beaches" and specific beach names such as "Bondi" and "Manly" suggests that proximity to the coast is a crucial factor for users in Australia.
- Terms such as "suburb", "harbor", and "wharf" also show interest in residential areas close to the coast and urban areas.

Canada
- Montreal is clearly the center of attention in Canada, with multiple related terms such as "Montreal", "downtown", and "metro".
- Terms such as "parc" (park), "logement" (accommodation), "salle" (room), and "pied" (foot, referring to proximity or walkability) highlight the importance of accessibility, green spaces, and amenities.
- The predominance of French terms underscores the need for bilingual content in Montreal listings.

United States
- "Manhattan", "Brooklyn", and "NYC" are dominant terms, reflecting the huge demand for properties in New York, one of the most visited cities in the world.
- Tourist Destinations: "Hawaii" and associated terms such as "beaches", "lanai", "waikiki" suggest strong interest in popular vacation destinations.
- The appearance of "condo" and "remodeled" indicate that users value modern and renovated properties.
	
**Distribution of Frequencies Analysis**
- Australia and the United States: Both regions show a high concentration of terms on the far left of the frequency distribution graph, indicating that a small number of terms are extremely common in the descriptions, this indicates that these markets are more homogeneous, with many listings focusing on similar locations and characteristics.
 
- Canada: The graph shows a slightly more dispersed distribution compared to Australia and the United States, indicating a greater diversity in the terms used. This could be related to the linguistic duality (French and English) and the diverse characteristics that users value in different regions of the country.
 
- All Markets: The long tail of terms with low frequency suggests the existence of niche markets that are not being fully exploited. Less common terms could represent unique characteristics of certain properties or less popular but growing areas.
	


**Recommendations**

- For these markets, Airbnb should consider diversifying the use of terms in its listings to avoid saturation of certain terms and highlight unique characteristics of the properties. This may help attract a market segment that is looking for something different or specific.

- Airbnb should continue to customize descriptions in Canada, not only on a language level, but also considering cultural and regional differences. This diversity could be an advantage if properly exploited in marketing campaigns that segment specific audiences.

- Airbnb could benefit from further analyzing these low-frequency terms to identify unsaturated market opportunities, this could include creating targeted campaigns for properties that offer features or locations that are not being widely promoted, but could appeal to a specific niche of users.

- The frequency distribution indicates that there are many opportunities to differentiate listings in saturated markets such as the United States and Australia, rather than competing solely on the most common terms, Airbnb can improve its SEO by focusing on long-tail terms that are not yet widely used, which could increase the visibility of less conventional properties.


<a href="Rentals_prediction_Divvy.ipynb">Download the Jupyter file</a>


