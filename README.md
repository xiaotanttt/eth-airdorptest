graph TD
    A[主资金池合约] --> B[子分发合约1]
    A --> C[子分发合约2]
    A --> D[子分发合约3]
    A --> E[子分发合约4]
    A --> F[子分发合约5]
    B --> G[钱包组1-3]
    B --> H[钱包组4-6]
    B --> I[钱包组7-9]
    C --> J[...]




    部署阶段
    sequenceDiagram
    Owner->>Factory: 调用deployFullSystem
    Factory->>ChildDistributor: 部署5个子合约
    Factory->>MainPool: 部署主合约并关联子合约


    资金分配阶段
    sequenceDiagram
    Owner->>MainPool: 转入资金
    Owner->>MainPool: 调用distributeToChildren()
    MainPool->>ChildDistributor: 分配1/5资金
    ChildDistributor->>WalletGroup: 每组分配1/5资金
