# SmartDroplets Kubernetes Deployment

This project contains Kubernetes configuration files for deploying SmartDroplets components to a Kubernetes cluster.

## Project Structure

There are currently 6 cloud components in the SD cloud. Their _deployment_ and _service_ configurations are stored separately, based on the components, within subdirectories of the _k8s/_ directory.

```
.
├── README.md
├── k8s
│   ├── cratedb/
│   ├── dashboard/
│   ├── digitaltwin/
│   ├── orion/
│   ├── mongo/
│   └── quantumleap/
└── manage.sh
```

## Components

### Orion Context Broker

The Orion Context Broker is an implementation of the NGSI-LD API that allows you to manage the entire lifecycle of context information including updates, queries, registrations, and subscriptions. It is a core component of the FIWARE platform that enables the management of context information in a highly decentralized and large-scale manner.

Key features:
- NGSI-LD compliant API
- Real-time updates and notifications
- Query and subscription capabilities
- JSON-LD data format support

### CrateDB
CrateDB is a distributed SQL database built on top of a NoSQL foundation. It combines the familiarity of SQL with the scalability and data flexibility of NoSQL. In this architecture, it serves as the time-series database backend for QuantumLeap.

Key features:
- Distributed SQL database
- Real-time analytics
- Time-series data optimization
- Horizontal scalability

### MongoDB
MongoDB is used as the primary database for the Orion Context Broker. It stores all context data and subscription information managed by Orion.

Key features:
- Document-oriented database
- High performance
- High availability
- Automatic scaling

### QuantumLeap
QuantumLeap is a REST service for storing, querying, and retrieving NGSI v2 and NGSI-LD spatial-temporal data. It acts as a connector between Orion Context Broker and time-series databases (in this case, CrateDB).

Key features:
- Time-series data storage
- Geospatial queries
- Multi-tenancy support
- Integration with various time-series databases


## Deployment

To deploy the components to your Kubernetes cluster, use the following command:

```bash
kubectl apply -f k8s/
```

This will apply all the Kubernetes configuration files in the k8s/ directory and its subdirectories.


## Configuration

Each component may have specific configuration options. Refer to the individual YAML files for detailed configuration settings.

## Prerequisites

* Kubernetes cluster

* kubectl configured to communicate with your cluster

* Required images pulled and accessible to your cluster

## Monitoring and Logging

Refer to your Kubernetes cluster's monitoring and logging solutions for observing the deployed components.

