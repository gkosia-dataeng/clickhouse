## Module 1: Introduction to ClickHouse

### ClickHouse Use Cases

- **Real-time Analytics**  
  ClickHouse is a real-time analytical database designed for high-performance queries.  
  It is commonly used to power real-time workloads and interactive dashboards.

- **Observability**  
  ClickHouse can be used to analyze logs, events, and traces for monitoring and troubleshooting.
  
  - **ClickStack**: Uses an OpenTelemetry (OTEL) Collector as a gateway for systems to send logs and telemetry data to ClickHouse.
  - **HyperDX**: Built on top of ClickHouse to visualize and explore observability data.

- **Data Warehouse**  
  ClickHouse acts as an OLAP database optimized for analytical workloads and large-scale data exploration.

- **AI and Machine Learning**  
  ClickHouse can be used in AI and ML workflows, including:
  - MCP servers
  - Integration with LLM-based models

---

### Running ClickHouse

- **ClickHouse Cloud**  
  A fully managed ClickHouse service.

- **Self-Managed Deployment**  
  Run ClickHouse on your own infrastructure:
  - Using Docker
  - By downloading and running the ClickHouse binaries locally
    - Start the ClickHouse server application
