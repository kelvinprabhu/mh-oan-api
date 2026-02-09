# Beckn Network Tools - Request/Response Documentation

This document provides comprehensive details about all Beckn network tools used in the OpenAgriNet (OAN) API, including their request and response structures for mock server implementation.

## Table of Contents

1. [Overview](#overview)
2. [Common Models](#common-models)
3. [Tool 1: Agricultural Services](#1-agricultural-services)
4. [Tool 2: Weather Data](#2-weather-data)
5. [Tool 3: Staff Contact](#3-staff-contact)
6. [Tool 4: Scheme Information](#4-scheme-information)
7. [Tool 5: Mandi/Market Prices](#5-mandimarket-prices)
8. [Tool 6: MahaDBT Scheme Status](#6-mahadbt-scheme-status)
9. [Tool 7: AgriStack Farmer Information](#7-agristack-farmer-information)
10. [Mock Server Configuration](#mock-server-configuration)

---

## Overview

All Beckn network tools follow the standard Beckn protocol structure with:
- **Context**: Metadata about the request/response
- **Message**: The actual data payload

**Base Endpoint**: Configured via `BAP_ENDPOINT` environment variable

**Standard Headers**:
```json
{
  "Content-Type": "application/json"
}
```

---

## Common Models

### Context (Request)

```json
{
  "domain": "string",           // e.g., "advisory:mh-vistaar"
  "action": "search",
  "version": "1.1.0",
  "bap_id": "string",           // BAP ID from env
  "bap_uri": "string",          // BAP URI from env
  "bpp_id": "string",           // BPP ID from env
  "bpp_uri": "string",          // BPP URI from env
  "message_id": "uuid",         // Unique message ID
  "transaction_id": "uuid",     // Unique transaction ID
  "timestamp": "ISO8601_string",// e.g., "2024-01-15T10:30:00.000Z"
  "location": {
    "country": {
      "name": "India",
      "code": "IND"
    }
  }
}
```

### Descriptor

```json
{
  "code": "string",             // Optional
  "name": "string",             // Optional
  "short_desc": "string",       // Optional
  "long_desc": "string",        // Optional
  "images": [                   // Optional
    {
      "url": "https://example.com/image.jpg"
    }
  ]
}
```

### Tag Structure

```json
{
  "descriptor": {
    "code": "string",
    "name": "string"
  },
  "list": [
    {
      "descriptor": {
        "code": "tag_key",
        "name": "Tag Name"
      },
      "value": "tag_value"
    }
  ]
}
```

---

## 1. Agricultural Services

**Purpose**: Fetch agricultural service locations (KVK, CHC, Soil Labs, Warehouses)

**File**: `agents/tools/agri_services.py`

**Function**: `agri_services(latitude, longitude, category_code)`

### Request Structure

**Method**: `POST`

**Endpoint**: `{BAP_ENDPOINT}`

**Parameters**:
- `latitude` (float): Location latitude
- `longitude` (float): Location longitude
- `category_code` (string): One of `["kvk", "chc", "soil_lab", "warehouse"]`

**Request Body**:
```json
{
  "context": {
    "domain": "advisory:mh-vistaar",
    "location": {
      "country": {
        "name": "IND"
      }
    },
    "action": "search",
    "version": "1.1.0",
    "bap_id": "oan-mock",
    "bap_uri": "http://localhost:8001",
    "bpp_id": "pocra-bpp-id",
    "bpp_uri": "https://bpp.example.com",
    "message_id": "550e8400-e29b-41d4-a716-446655440000",
    "transaction_id": "550e8400-e29b-41d4-a716-446655440001",
    "timestamp": "2024-01-15T10:30:00.000000Z"
  },
  "message": {
    "intent": {
      "category": {
        "descriptor": {
          "code": "kvk"
        }
      },
      "item": {
        "descriptor": {
          "name": "service-locations"
        }
      },
      "fulfillment": {
        "stops": [
          {
            "location": {
              "gps": "18.5204,73.8567"
            }
          }
        ]
      }
    }
  }
}
```

### Response Structure

```json
{
  "context": {
    "domain": "advisory:mh-vistaar",
    "action": "on_search",
    "version": "1.1.0",
    "bap_id": "oan-mock",
    "bap_uri": "http://localhost:8001",
    "bpp_id": "pocra-bpp-id",
    "bpp_uri": "https://bpp.example.com",
    "message_id": "550e8400-e29b-41d4-a716-446655440000",
    "transaction_id": "550e8400-e29b-41d4-a716-446655440001",
    "timestamp": "2024-01-15T10:30:05.000000Z"
  },
  "responses": [
    {
      "context": {},
      "message": {
        "catalog": {
          "descriptor": {
            "name": "Agricultural Services Catalog"
          },
          "providers": [
            {
              "id": "provider-1",
              "descriptor": {
                "code": "KVK-001",
                "name": "Pune District KVK",
                "short_desc": "Krishi Vigyan Kendra providing agricultural extension services",
                "long_desc": "Complete agricultural training and advisory services"
              },
              "items": [
                {
                  "id": "item-1",
                  "descriptor": {
                    "code": "kvk",
                    "name": "Pune KVK Main Center",
                    "short_desc": "Main agricultural extension center"
                  },
                  "address": {
                    "address": "Main Road, Agriculture University Campus",
                    "district": "Pune",
                    "region": "Western Maharashtra",
                    "taluka": "Haveli",
                    "village": "Shivajinagar",
                    "pinCode": "411001"
                  },
                  "contact": {
                    "person": "Dr. Ramesh Patil",
                    "email": "kvkpune@example.com",
                    "phone": "+91-20-12345678",
                    "webUrl": "https://kvkpune.example.com"
                  },
                  "creator": {
                    "descriptor": {
                      "name": "Maharashtra Agriculture Department"
                    }
                  },
                  "tags": [
                    {
                      "descriptor": {
                        "code": "location_data"
                      },
                      "list": [
                        {
                          "descriptor": {
                            "code": "distance",
                            "name": "Distance"
                          },
                          "value": "5.2 km"
                        }
                      ]
                    }
                  ]
                }
              ]
            }
          ]
        }
      }
    }
  ]
}
```

**Category Codes**:
- `kvk`: Krishi Vigyan Kendra (Agricultural Science Center)
- `chc`: Custom Hiring Center
- `soil_lab`: Soil Testing Laboratory
- `warehouse`: Storage Warehouse

---

## 2. Weather Data

**Purpose**: Fetch weather forecast or historical weather data

**File**: `agents/tools/weather.py`

**Function**: `get_weather(latitude, longitude, days, request_type)`

### Request Structure

**Method**: `POST`

**Endpoint**: `{BAP_ENDPOINT}`

**Parameters**:
- `latitude` (float): Location latitude
- `longitude` (float): Location longitude
- `days` (int): Number of days (default: 5 for forecast, 7 for historical)
- `request_type` (string): Either `"forecast"` or `"historical"`

**Request Body (Forecast)**:
```json
{
  "context": {
    "ttl": "PT10M",
    "action": "search",
    "timestamp": "2024-01-15T10:30:00.000Z",
    "message_id": "550e8400-e29b-41d4-a716-446655440000",
    "transaction_id": "550e8400-e29b-41d4-a716-446655440001",
    "domain": "advisory:weather:mh-vistaar",
    "version": "1.1.0",
    "bap_id": "oan-mock",
    "bap_uri": "http://localhost:8001",
    "bpp_id": "pocra-bpp-id",
    "bpp_uri": "https://bpp.example.com",
    "location": {
      "country": {
        "name": "India",
        "code": "IND"
      }
    }
  },
  "message": {
    "intent": {
      "category": {
        "descriptor": {
          "name": "Weather-Forecast"
        }
      },
      "item": {
        "time": {
          "range": {
            "start": "2024-01-15T00:00:00Z",
            "end": "2024-01-20T00:00:00Z"
          }
        }
      },
      "fulfillment": {
        "stops": [
          {
            "location": {
              "gps": "18.5204, 73.8567"
            }
          }
        ]
      }
    }
  }
}
```

**Request Body (Historical)**:
```json
{
  "context": {
    "ttl": "PT10M",
    "action": "search",
    "timestamp": "2024-01-15T10:30:00.000Z",
    "message_id": "550e8400-e29b-41d4-a716-446655440002",
    "transaction_id": "550e8400-e29b-41d4-a716-446655440003",
    "domain": "advisory:weather:mh-vistaar",
    "version": "1.1.0",
    "bap_id": "oan-mock",
    "bap_uri": "http://localhost:8001",
    "bpp_id": "pocra-bpp-id",
    "bpp_uri": "https://bpp.example.com",
    "location": {
      "country": {
        "name": "India",
        "code": "IND"
      }
    }
  },
  "message": {
    "intent": {
      "category": {
        "descriptor": {
          "name": "Weather-Historical"
        }
      },
      "item": {
        "time": {
          "range": {
            "start": "2024-01-08T00:00:00Z",
            "end": "2024-01-15T00:00:00Z"
          }
        }
      },
      "fulfillment": {
        "stops": [
          {
            "location": {
              "gps": "18.5204, 73.8567"
            }
          }
        ]
      }
    }
  }
}
```

### Response Structure

```json
{
  "context": {
    "domain": "advisory:weather:mh-vistaar",
    "action": "on_search",
    "version": "1.1.0",
    "bap_id": "oan-mock",
    "bap_uri": "http://localhost:8001",
    "bpp_id": "pocra-bpp-id",
    "bpp_uri": "https://bpp.example.com",
    "message_id": "550e8400-e29b-41d4-a716-446655440000",
    "transaction_id": "550e8400-e29b-41d4-a716-446655440001",
    "timestamp": "2024-01-15T10:30:05.000Z"
  },
  "responses": [
    {
      "context": {},
      "message": {
        "catalog": {
          "descriptor": {
            "name": "Weather Data"
          },
          "providers": [
            {
              "id": "weather-provider-1",
              "descriptor": {
                "name": "Maharashtra Weather Service"
              },
              "items": [
                {
                  "id": "weather-day-1",
                  "descriptor": {
                    "code": "2024-01-15",
                    "name": "Weather for 2024-01-15"
                  },
                  "tags": [
                    {
                      "descriptor": {
                        "code": "temperature",
                        "name": "Temperature"
                      },
                      "list": [
                        {
                          "descriptor": {
                            "code": "min",
                            "name": "Minimum"
                          },
                          "value": "18"
                        },
                        {
                          "descriptor": {
                            "code": "max",
                            "name": "Maximum"
                          },
                          "value": "28"
                        }
                      ]
                    },
                    {
                      "descriptor": {
                        "code": "rainfall",
                        "name": "Rainfall"
                      },
                      "list": [
                        {
                          "descriptor": {
                            "code": "amount",
                            "name": "Amount"
                          },
                          "value": "5.2"
                        }
                      ]
                    },
                    {
                      "descriptor": {
                        "code": "humidity",
                        "name": "Humidity"
                      },
                      "list": [
                        {
                          "descriptor": {
                            "code": "percentage",
                            "name": "Percentage"
                          },
                          "value": "65"
                        }
                      ]
                    },
                    {
                      "descriptor": {
                        "code": "wind",
                        "name": "Wind"
                      },
                      "list": [
                        {
                          "descriptor": {
                            "code": "speed",
                            "name": "Speed"
                          },
                          "value": "12"
                        },
                        {
                          "descriptor": {
                            "code": "direction",
                            "name": "Direction"
                          },
                          "value": "NW"
                        }
                      ]
                    }
                  ]
                }
              ]
            }
          ]
        }
      }
    }
  ]
}
```

---

## 3. Staff Contact

**Purpose**: Get administrative information and officer contact details

**File**: `agents/tools/staff_contact.py`

### 3.1 Administrative Information (Village Info)

**Function**: `get_admin_info(latitude, longitude)`

#### Request Structure

**Method**: `POST`

**Endpoint**: `{BAP_ENDPOINT}`

**Request Body**:
```json
{
  "context": {
    "domain": "advisory:mh-vistaar",
    "location": {
      "country": {
        "name": "IND"
      }
    },
    "action": "search",
    "version": "1.1.0",
    "bap_id": "oan-mock",
    "bap_uri": "http://localhost:8001",
    "bpp_id": "pocra-bpp-id",
    "bpp_uri": "https://bpp.example.com",
    "message_id": "550e8400-e29b-41d4-a716-446655440000",
    "transaction_id": "550e8400-e29b-41d4-a716-446655440001",
    "timestamp": "2024-01-15T10:30:00.000Z"
  },
  "message": {
    "intent": {
      "category": {
        "descriptor": {
          "code": "village-information"
        }
      },
      "fulfillment": {
        "stops": [
          {
            "location": {
              "gps": "18.5204,73.8567"
            }
          }
        ]
      }
    }
  }
}
```

#### Response Structure

```json
{
  "context": {
    "domain": "advisory:mh-vistaar",
    "action": "on_search",
    "version": "1.1.0",
    "bap_id": "oan-mock",
    "bap_uri": "http://localhost:8001",
    "bpp_id": "pocra-bpp-id",
    "bpp_uri": "https://bpp.example.com",
    "message_id": "550e8400-e29b-41d4-a716-446655440000",
    "transaction_id": "550e8400-e29b-41d4-a716-446655440001",
    "timestamp": "2024-01-15T10:30:05.000Z"
  },
  "responses": [
    {
      "context": {},
      "message": {
        "catalog": {
          "providers": [
            {
              "id": "admin-provider-1",
              "descriptor": {
                "name": "Administrative Information"
              },
              "items": [
                {
                  "id": "village-1",
                  "descriptor": {
                    "name": "Shivajinagar"
                  },
                  "tags": [
                    {
                      "descriptor": {
                        "code": "administrative_info"
                      },
                      "list": [
                        {
                          "descriptor": {
                            "code": "village_code",
                            "name": "Village Code"
                          },
                          "value": "413201"
                        },
                        {
                          "descriptor": {
                            "code": "village_name",
                            "name": "Village Name"
                          },
                          "value": "Shivajinagar"
                        },
                        {
                          "descriptor": {
                            "code": "taluka_name",
                            "name": "Taluka Name"
                          },
                          "value": "Haveli"
                        },
                        {
                          "descriptor": {
                            "code": "district_name",
                            "name": "District Name"
                          },
                          "value": "Pune"
                        }
                      ]
                    }
                  ]
                }
              ]
            }
          ]
        }
      }
    }
  ]
}
```

### 3.2 Officer Contact Details

**Function**: `get_officer_contact(village_code, data_category)`

#### Request Structure

**Method**: `POST`

**Endpoint**: `{BAP_ENDPOINT}`

**Parameters**:
- `village_code` (string): Village code from administrative info
- `data_category` (string): Officer type code (default: "aa")

**Request Body**:
```json
{
  "context": {
    "domain": "advisory:mh-vistaar",
    "location": {
      "country": {
        "name": "IND"
      }
    },
    "action": "search",
    "version": "1.1.0",
    "bap_id": "oan-mock",
    "bap_uri": "http://localhost:8001",
    "bpp_id": "pocra-bpp-id",
    "bpp_uri": "https://bpp.example.com",
    "message_id": "550e8400-e29b-41d4-a716-446655440002",
    "transaction_id": "550e8400-e29b-41d4-a716-446655440003",
    "timestamp": "2024-01-15T10:30:10.000Z"
  },
  "message": {
    "intent": {
      "category": {
        "descriptor": {
          "code": "officer-details"
        }
      },
      "item": {
        "descriptor": {
          "code": "413201"
        }
      },
      "fulfillment": {
        "tags": [
          {
            "descriptor": {
              "code": "data_category"
            },
            "list": [
              {
                "descriptor": {
                  "code": "data_category"
                },
                "value": "aa"
              }
            ]
          }
        ]
      }
    }
  }
}
```

#### Response Structure

```json
{
  "context": {
    "domain": "advisory:mh-vistaar",
    "action": "on_search",
    "version": "1.1.0",
    "bap_id": "oan-mock",
    "bap_uri": "http://localhost:8001",
    "bpp_id": "pocra-bpp-id",
    "bpp_uri": "https://bpp.example.com",
    "message_id": "550e8400-e29b-41d4-a716-446655440002",
    "transaction_id": "550e8400-e29b-41d4-a716-446655440003",
    "timestamp": "2024-01-15T10:30:15.000Z"
  },
  "responses": [
    {
      "context": {},
      "message": {
        "catalog": {
          "providers": [
            {
              "id": "officer-provider-1",
              "descriptor": {
                "name": "Officer Directory"
              },
              "items": [
                {
                  "id": "officer-1",
                  "descriptor": {
                    "name": "Agriculture Assistant"
                  },
                  "contact": {
                    "person": "Mr. Suresh Deshmukh",
                    "email": "suresh.d@example.com",
                    "phone": "+91-20-98765432"
                  },
                  "address": {
                    "district": "Pune",
                    "taluka": "Haveli",
                    "village": "Shivajinagar"
                  },
                  "tags": [
                    {
                      "descriptor": {
                        "code": "officer_info"
                      },
                      "list": [
                        {
                          "descriptor": {
                            "code": "designation",
                            "name": "Designation"
                          },
                          "value": "Agriculture Assistant"
                        },
                        {
                          "descriptor": {
                            "code": "department",
                            "name": "Department"
                          },
                          "value": "Agriculture Department"
                        }
                      ]
                    }
                  ]
                }
              ]
            }
          ]
        }
      }
    }
  ]
}
```

---

## 4. Scheme Information

**Purpose**: Get detailed information about agricultural schemes

**File**: `agents/tools/scheme_info.py`

**Function**: `get_scheme_info(scheme_code)`

### Request Structure

**Method**: `POST`

**Endpoint**: `{BAP_ENDPOINT}`

**Parameters**:
- `scheme_code` (string): Code of the scheme (e.g., "pmfby", "pmkisan", "nsmnyy")

**Request Body**:
```json
{
  "context": {
    "domain": "advisory:mh-vistaar",
    "location": {
      "country": {
        "name": "IND"
      }
    },
    "action": "search",
    "version": "1.1.0",
    "bap_id": "oan-mock",
    "bap_uri": "http://localhost:8001",
    "bpp_id": "pocra-bpp-id",
    "bpp_uri": "https://bpp.example.com",
    "message_id": "550e8400-e29b-41d4-a716-446655440000",
    "transaction_id": "550e8400-e29b-41d4-a716-446655440001",
    "timestamp": "2024-01-15T10:30:00.000Z"
  },
  "message": {
    "intent": {
      "category": {
        "descriptor": {
          "code": "schemes-agri"
        }
      },
      "item": {
        "descriptor": {
          "code": "pmfby"
        }
      }
    }
  }
}
```

### Response Structure

```json
{
  "context": {
    "domain": "advisory:mh-vistaar",
    "action": "on_search",
    "version": "1.1.0",
    "bap_id": "oan-mock",
    "bap_uri": "http://localhost:8001",
    "bpp_id": "pocra-bpp-id",
    "bpp_uri": "https://bpp.example.com",
    "message_id": "550e8400-e29b-41d4-a716-446655440000",
    "transaction_id": "550e8400-e29b-41d4-a716-446655440001",
    "timestamp": "2024-01-15T10:30:05.000Z"
  },
  "responses": [
    {
      "context": {},
      "message": {
        "catalog": {
          "providers": [
            {
              "id": "scheme-provider-1",
              "descriptor": {
                "name": "Agricultural Schemes"
              },
              "items": [
                {
                  "id": "pmfby",
                  "descriptor": {
                    "code": "pmfby",
                    "name": "Pradhan Mantri Fasal Bima Yojana",
                    "short_desc": "Crop Insurance Scheme",
                    "long_desc": "The Pradhan Mantri Fasal Bima Yojana (PMFBY) aims to provide insurance coverage and financial support to farmers in case of crop failure, ensuring their financial stability."
                  },
                  "tags": [
                    {
                      "display": true,
                      "descriptor": {
                        "code": "scheme_details",
                        "name": "Scheme Details"
                      },
                      "list": [
                        {
                          "descriptor": {
                            "code": "eligibility",
                            "name": "Eligibility"
                          },
                          "value": "All farmers including sharecroppers and tenant farmers",
                          "display": true
                        },
                        {
                          "descriptor": {
                            "code": "benefits",
                            "name": "Benefits"
                          },
                          "value": "Comprehensive risk insurance coverage for crops",
                          "display": true
                        },
                        {
                          "descriptor": {
                            "code": "premium",
                            "name": "Premium"
                          },
                          "value": "2% for Kharif, 1.5% for Rabi crops",
                          "display": true
                        },
                        {
                          "descriptor": {
                            "code": "application_process",
                            "name": "Application Process"
                          },
                          "value": "Apply through banks, CSCs, or online portal",
                          "display": true
                        },
                        {
                          "descriptor": {
                            "code": "documents_required",
                            "name": "Documents Required"
                          },
                          "value": "Aadhaar, Bank Account, Land Records",
                          "display": true
                        }
                      ]
                    }
                  ]
                }
              ]
            }
          ]
        }
      }
    }
  ]
}
```

**Available Scheme Codes**:

**State Schemes**:
- `nsmnyy` - Namo Shetkari Mahasanman Nidhi Yojana
- `bmkky` - Baliraja Mkaran va Kharedi Yojana
- `gmsassay` - Gomata and Matsya Sanjivani Aarogya Sabha Yojana
- `cmsaisfp` - CM Subsidy for Agriculture Inputs Scheme for Farmers
- `baksy` - Baliraja Khate Sinchan Yojana
- `bfhps` - Beneficiary Farmer Horticulture Plantation Scheme
- `sericulture`, `agroforestry`, `bamboo`, `horticulture`, `apiculture`
- `planting-material-polyhouse`, `drip-irrigation`, `inland-fishery`

**Central Schemes**:
- `rwbcis` - Restructured Weather Based Crop Insurance Scheme
- `pmfby` - Pradhan Mantri Fasal Bima Yojana
- `aif` - Agriculture Infrastructure Fund
- `kymidh` - Kisan Yuva Mahila Irrigation Development Horticulture
- `pmkisan` - PM Kisan Samman Nidhi
- `pmkmy` - Pradhan Mantri Kisan Maan Dhan Yojana
- `pmrkvysmam` - PM Rashtriya Krishi Vikas Yojana Sub Mission on Agricultural Mechanization
- `pmkrvypdmc` - PM Kisan Rashtriya Vikas Yojana Paramparagat Krishi Vikas
- `mgnregs` - Mahatma Gandhi National Rural Employment Guarantee Scheme
- `pmfmfpes` - PM Formalization of Micro Food Processing Enterprises Scheme

---

## 5. Mandi/Market Prices

**Purpose**: Get current market prices for agricultural commodities

**File**: `agents/tools/mandi.py`

**Function**: `get_mandi_prices(latitude, longitude)`

### Request Structure

**Method**: `POST`

**Endpoint**: `{BAP_ENDPOINT}`

**Parameters**:
- `latitude` (float): Location latitude
- `longitude` (float): Location longitude

**Request Body**:
```json
{
  "context": {
    "domain": "advisory:mh-vistaar",
    "action": "search",
    "location": {
      "country": {
        "name": "India",
        "code": "IND"
      }
    },
    "version": "1.1.0",
    "bap_id": "oan-mock",
    "bap_uri": "http://localhost:8001",
    "bpp_id": "pocra-bpp-id",
    "bpp_uri": "https://bpp.example.com",
    "message_id": "550e8400-e29b-41d4-a716-446655440000",
    "transaction_id": "550e8400-e29b-41d4-a716-446655440001",
    "timestamp": "2024-01-15T10:30:00.000000Z"
  },
  "message": {
    "intent": {
      "category": {
        "descriptor": {
          "code": "price-discovery"
        }
      },
      "item": {
        "descriptor": {
          "code": ""
        }
      },
      "fulfillment": {
        "stops": [
          {
            "location": {
              "gps": "18.5204, 73.8567"
            }
          }
        ]
      }
    }
  }
}
```

### Response Structure

```json
{
  "context": {
    "domain": "advisory:mh-vistaar",
    "action": "on_search",
    "version": "1.1.0",
    "bap_id": "oan-mock",
    "bap_uri": "http://localhost:8001",
    "bpp_id": "pocra-bpp-id",
    "bpp_uri": "https://bpp.example.com",
    "message_id": "550e8400-e29b-41d4-a716-446655440000",
    "transaction_id": "550e8400-e29b-41d4-a716-446655440001",
    "timestamp": "2024-01-15T10:30:05.000000Z"
  },
  "responses": [
    {
      "context": {},
      "message": {
        "catalog": {
          "providers": [
            {
              "id": "mandi-provider-1",
              "descriptor": {
                "name": "Market Price Information"
              },
              "locations": [
                {
                  "id": "loc-1",
                  "city": {
                    "name": "Pune"
                  }
                }
              ],
              "items": [
                {
                  "id": "item-1",
                  "descriptor": {
                    "code": "wheat",
                    "name": "Wheat (गहू)"
                  },
                  "location_ids": ["loc-1"],
                  "price": {
                    "minimum_value": "2000",
                    "maximum_value": "2200",
                    "estimated_value": "2100"
                  },
                  "time": {
                    "label": "reported_date",
                    "timestamp": "2024-01-14T00:00:00Z"
                  }
                },
                {
                  "id": "item-2",
                  "descriptor": {
                    "code": "onion",
                    "name": "Onion (कांदा)"
                  },
                  "location_ids": ["loc-1"],
                  "price": {
                    "minimum_value": "1500",
                    "maximum_value": "1800",
                    "estimated_value": "1650"
                  },
                  "time": {
                    "label": "reported_date",
                    "timestamp": "2024-01-14T00:00:00Z"
                  }
                }
              ]
            }
          ]
        }
      }
    }
  ]
}
```

**Price Details**:
- All prices are in INR per quintal (₹/quintal)
- `minimum_value`: Minimum price reported
- `maximum_value`: Maximum price reported
- `estimated_value`: Average/estimated price

---

## 6. MahaDBT Scheme Status

**Purpose**: Check farmer's scheme application status in MahaDBT system

**File**: `agents/tools/mahadbt.py`

**Function**: `get_scheme_status(farmer_id)`

### Request Structure

**Method**: `POST`

**Endpoint**: `{BAP_ENDPOINT}`

**Parameters**:
- `farmer_id` (string): Farmer's unique identifier

**Request Body**:
```json
{
  "context": {
    "domain": "mahadbt:mh-vistaar",
    "ttl": "PT10S",
    "action": "search",
    "version": "1.1.0",
    "bap_id": "oan-mock",
    "bap_uri": "http://localhost:8001",
    "bpp_id": "mahadbt-bpp-id",
    "bpp_uri": "https://mahadbt-bpp.example.com",
    "message_id": "550e8400-e29b-41d4-a716-446655440000",
    "transaction_id": "550e8400-e29b-41d4-a716-446655440001",
    "timestamp": "1705315800",
    "location": {
      "country": {
        "name": "India",
        "code": "IND"
      }
    }
  },
  "message": {
    "intent": {
      "category": {
        "descriptor": {
          "code": "farmer-details-info"
        }
      },
      "item": {
        "id": "FARMER123456"
      }
    }
  }
}
```

### Response Structure

```json
{
  "context": {
    "domain": "mahadbt:mh-vistaar",
    "action": "on_search",
    "version": "1.1.0",
    "bap_id": "oan-mock",
    "bap_uri": "http://localhost:8001",
    "bpp_id": "mahadbt-bpp-id",
    "bpp_uri": "https://mahadbt-bpp.example.com",
    "message_id": "550e8400-e29b-41d4-a716-446655440000",
    "transaction_id": "550e8400-e29b-41d4-a716-446655440001",
    "timestamp": "1705315805"
  },
  "responses": [
    {
      "context": {},
      "message": {
        "catalog": {
          "providers": [
            {
              "id": "mahadbt-provider-1",
              "descriptor": {
                "name": "MahaDBT Scheme Applications"
              },
              "items": [
                {
                  "id": "application-1",
                  "descriptor": {
                    "code": "pmfby",
                    "name": "Pradhan Mantri Fasal Bima Yojana"
                  },
                  "tags": [
                    {
                      "code": "status",
                      "value": "Fund Disbursed"
                    },
                    {
                      "code": "application_id",
                      "value": "APP2024001234"
                    },
                    {
                      "code": "applied_date",
                      "value": "2023-12-01"
                    },
                    {
                      "code": "sanctioned_amount",
                      "value": "50000"
                    },
                    {
                      "code": "disbursed_amount",
                      "value": "50000"
                    },
                    {
                      "code": "disbursement_date",
                      "value": "2024-01-10"
                    }
                  ]
                },
                {
                  "id": "application-2",
                  "descriptor": {
                    "code": "drip-irrigation",
                    "name": "Drip Irrigation Subsidy"
                  },
                  "tags": [
                    {
                      "code": "status",
                      "value": "Under Review"
                    },
                    {
                      "code": "application_id",
                      "value": "APP2024001567"
                    },
                    {
                      "code": "applied_date",
                      "value": "2024-01-05"
                    },
                    {
                      "code": "sanctioned_amount",
                      "value": "0"
                    }
                  ]
                }
              ]
            }
          ]
        }
      }
    }
  ]
}
```

**Status Values** (with translations):
- `Fund Disbursed` - ✅ Fund Disbursed (पैसे दिले गेले)
- `Winner` - 🏆 Winner (निवड झाली)
- `Wait List` - ⏳ Wait List (प्रतीक्षा यादीत आहे)
- `Approved` - ✅ Approved (अर्ज मंजूर झाला)
- `Rejected` - ❌ Rejected (अर्ज नाकारला)
- `Under Review` - 📋 Under Review (अर्ज तपासणीमध्ये आहे)
- `Pending` - ⏳ Pending (अर्ज थांबलेला आहे)
- `Upload Documents` - 📄 Upload Documents (कागदपत्रे टाका)
- `Department Cancelled` - 🚫 Department Cancelled (विभागाने अर्ज रद्द केला)

---

## 7. AgriStack Farmer Information

**Purpose**: Fetch farmer profile and farm details from AgriStack

**File**: `agents/tools/agristack.py`

**Function**: `fetch_agristack_data(farmer_id)`

### Request Structure

**Method**: `POST`

**Endpoint**: `{BAP_ENDPOINT}`

**Parameters**:
- `farmer_id` (string): Farmer's unique identifier

**Request Body**:
```json
{
  "context": {
    "domain": "advisory:mh-vistaar",
    "action": "search",
    "version": "1.1.0",
    "bap_id": "oan-mock",
    "bap_uri": "http://localhost:8001",
    "bpp_id": "pocra-bpp-id",
    "bpp_uri": "https://bpp.example.com",
    "location": {
      "country": {
        "name": "India",
        "code": "IND"
      }
    },
    "transaction_id": "550e8400-e29b-41d4-a716-446655440000",
    "message_id": "550e8400-e29b-41d4-a716-446655440001",
    "timestamp": "2024-01-15T10:30:00.000000Z"
  },
  "message": {
    "intent": {
      "category": {
        "descriptor": {
          "code": "agristack_farmer_info"
        }
      },
      "item": {
        "id": "FARMER123456"
      }
    }
  }
}
```

### Response Structure

```json
{
  "context": {
    "domain": "advisory:mh-vistaar",
    "action": "on_search",
    "version": "1.1.0",
    "bap_id": "oan-mock",
    "bap_uri": "http://localhost:8001",
    "bpp_id": "pocra-bpp-id",
    "bpp_uri": "https://bpp.example.com",
    "transaction_id": "550e8400-e29b-41d4-a716-446655440000",
    "message_id": "550e8400-e29b-41d4-a716-446655440001",
    "timestamp": "2024-01-15T10:30:05.000000Z"
  },
  "responses": [
    {
      "context": {},
      "message": {
        "catalog": {
          "providers": [
            {
              "id": "agristack-provider-1",
              "descriptor": {
                "name": "AgriStack Farmer Registry"
              },
              "items": [
                {
                  "id": "farmer-profile-1",
                  "descriptor": {
                    "code": "farmer_profile",
                    "name": "Farmer Profile"
                  },
                  "tags": [
                    {
                      "code": "farmer_id",
                      "value": "FARMER123456"
                    },
                    {
                      "code": "farmer_name_mr",
                      "value": "Ra***h"
                    },
                    {
                      "code": "mobile",
                      "value": "98***32"
                    },
                    {
                      "code": "email",
                      "value": "ra***l"
                    },
                    {
                      "code": "dob",
                      "value": "19***85"
                    },
                    {
                      "code": "gender",
                      "value": "Male"
                    },
                    {
                      "code": "caste_category",
                      "value": "Open"
                    },
                    {
                      "code": "village",
                      "value": "Shivajinagar"
                    },
                    {
                      "code": "taluka",
                      "value": "Haveli"
                    },
                    {
                      "code": "district",
                      "value": "Pune"
                    },
                    {
                      "code": "state",
                      "value": "Maharashtra"
                    },
                    {
                      "code": "lgd_village_code",
                      "value": "413201"
                    },
                    {
                      "code": "lgd_taluka_code",
                      "value": "4132"
                    },
                    {
                      "code": "lgd_district_code",
                      "value": "413"
                    },
                    {
                      "code": "gps_coordinates",
                      "value": "18.5204,73.8567"
                    },
                    {
                      "code": "total_plot_area",
                      "value": "2.5"
                    },
                    {
                      "code": "total_plot_area_unit",
                      "value": "hectares"
                    }
                  ]
                }
              ]
            }
          ]
        }
      }
    }
  ]
}
```

**PII Fields** (automatically masked):
- `mobile`, `email`, `farmer_name_mr`, `dob`
- `aadhar`, `pan`, `voter_id`, `driving_license`
- Masking pattern: Short values (≤2 chars) → `***`, Medium (3-4 chars) → `X***`, Long (5+) → `XX***X`

---

## Mock Server Configuration

### Environment Variables

Create a `.env` file with the following configuration:

```bash
# Beckn / ONDC Configuration - mock
BAP_ID=oan-mock
BAP_URI=http://localhost:8001
BAP_ENDPOINT=http://localhost:8001/api/v1/beckn

# BPP Configuration
POCRA_BPP_ID=pocra-bpp-mock
POCRA_BPP_URI=http://localhost:8002/bpp
MAHADBT_BPP_ID=mahadbt-bpp-mock
MAHADBT_BPP_URI=http://localhost:8003/bpp
```

### Mock Server Endpoints

Your mock server should expose the following endpoint:

```
POST /api/v1/beckn
```

### Request Routing Logic

Route requests based on the `context.domain` and `message.intent.category.descriptor.code`:

| Domain | Category Code | Tool |
|--------|---------------|------|
| `advisory:mh-vistaar` | `kvk`, `chc`, `soil_lab`, `warehouse` | Agricultural Services |
| `advisory:weather:mh-vistaar` | `Weather-Forecast`, `Weather-Historical` | Weather |
| `advisory:mh-vistaar` | `village-information` | Administrative Info |
| `advisory:mh-vistaar` | `officer-details` | Officer Contact |
| `advisory:mh-vistaar` | `schemes-agri` | Scheme Information |
| `advisory:mh-vistaar` | `price-discovery` | Mandi Prices |
| `mahadbt:mh-vistaar` | `farmer-details-info` | MahaDBT Status |
| `advisory:mh-vistaar` | `agristack_farmer_info` | AgriStack Data |

### Response Template

All responses should follow this structure:

```json
{
  "context": {
    // Echo request context with action changed to "on_search"
  },
  "responses": [
    {
      "context": {},
      "message": {
        "catalog": {
          "descriptor": {},
          "providers": [
            // Provider array
          ]
        }
      }
    }
  ]
}
```

### Status Codes

- `200` - Success
- `400` - Bad Request (invalid parameters)
- `404` - Not Found (no data available)
- `500` - Internal Server Error
- `503` - Service Unavailable (timeout/retry)

### Sample Mock Server Implementation (Python FastAPI)

```python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Dict, Any
import uuid
from datetime import datetime

app = FastAPI()

@app.post("/api/v1/beckn")
async def beckn_endpoint(request: Dict[str, Any]):
    """Main Beckn endpoint for all tools"""
    
    domain = request.get("context", {}).get("domain")
    category_code = request.get("message", {}).get("intent", {}).get("category", {}).get("descriptor", {}).get("code")
    
    # Route to appropriate handler
    if domain == "advisory:mh-vistaar":
        if category_code in ["kvk", "chc", "soil_lab", "warehouse"]:
            return handle_agri_services(request)
        elif category_code == "village-information":
            return handle_admin_info(request)
        elif category_code == "officer-details":
            return handle_officer_contact(request)
        elif category_code == "schemes-agri":
            return handle_scheme_info(request)
        elif category_code == "price-discovery":
            return handle_mandi_prices(request)
        elif category_code == "agristack_farmer_info":
            return handle_agristack(request)
    elif domain == "advisory:weather:mh-vistaar":
        return handle_weather(request)
    elif domain == "mahadbt:mh-vistaar":
        return handle_mahadbt(request)
    
    raise HTTPException(status_code=400, detail="Unknown request type")

def handle_agri_services(request: Dict[str, Any]) -> Dict[str, Any]:
    """Mock agricultural services response"""
    # Implementation here
    pass

# Add more handlers...
```

---

## Testing

### Sample cURL Commands

**Agricultural Services**:
```bash
curl -X POST http://localhost:8001/api/v1/beckn \
  -H "Content-Type: application/json" \
  -d '{
    "context": {
      "domain": "advisory:mh-vistaar",
      "action": "search",
      "version": "1.1.0",
      "bap_id": "oan-mock",
      "bap_uri": "http://localhost:8001",
      "message_id": "'$(uuidgen)'",
      "transaction_id": "'$(uuidgen)'",
      "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%S.000Z)'"
    },
    "message": {
      "intent": {
        "category": {"descriptor": {"code": "kvk"}},
        "item": {"descriptor": {"name": "service-locations"}},
        "fulfillment": {
          "stops": [{"location": {"gps": "18.5204,73.8567"}}]
        }
      }
    }
  }'
```

**Weather Forecast**:
```bash
curl -X POST http://localhost:8001/api/v1/beckn \
  -H "Content-Type: application/json" \
  -d '{
    "context": {
      "domain": "advisory:weather:mh-vistaar",
      "action": "search",
      "version": "1.1.0",
      "message_id": "'$(uuidgen)'",
      "transaction_id": "'$(uuidgen)'",
      "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%S.000Z)'"
    },
    "message": {
      "intent": {
        "category": {"descriptor": {"name": "Weather-Forecast"}},
        "item": {
          "time": {
            "range": {
              "start": "'$(date -u +%Y-%m-%dT00:00:00Z)'",
              "end": "'$(date -u -d '+5 days' +%Y-%m-%dT00:00:00Z)'"
            }
          }
        },
        "fulfillment": {
          "stops": [{"location": {"gps": "18.5204, 73.8567"}}]
        }
      }
    }
  }'
```

---

## Notes

1. **UUID Generation**: All `message_id` and `transaction_id` should be unique UUIDs
2. **Timestamps**: Use ISO 8601 format with UTC timezone
3. **GPS Coordinates**: Format as "latitude,longitude" (comma-separated)
4. **PII Masking**: Sensitive farmer data should be masked in responses
5. **Error Handling**: Implement proper error responses with appropriate status codes
6. **Timeouts**: Default timeout is 10 seconds for connection, 15 seconds for read
7. **Retry Logic**: Implement retry mechanism for failed requests

---

## Revision History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2024-01-15 | Initial documentation |

---

## Contact & Support

For questions or issues with this documentation, please contact the development team or refer to the main README.md file.
