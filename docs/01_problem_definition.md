# Problem Definition

## Problem
Design and operate a production-ready platform capable of hosting
a stateless web application with high availability and minimal
operational overhead.

## Users
- End users accessing the application over the internet
- Developers deploying application changes
- DevOps engineers responsible for reliability and security

## Availability Requirements
- No single point of failure
- Application remains available if a single instance or AZ fails

## High Availability Scope
- Entry point to the platform
- Compute layer
- Data layer

## Failure Tolerance
- Individual compute instances may fail
- A single Availability Zone may fail

## Security Assumptions
- No direct public access to backend resources
- Principle of least privilege applies to all components
- Data must be encrypted at rest and in transit

## Responsibility Boundaries
- AWS: physical data centers, underlying infrastructure
- Platform team: OS, application runtime, configuration, access control

## Automation Scope
- Infrastructure provisioning
- Application deployment
- Scaling and recovery

## Explicitly Out of Scope
- Multi-region deployments
- Kubernetes
- Advanced disaster recovery