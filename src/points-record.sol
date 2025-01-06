// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract CommunityPointsRecord {
    // 工作记录结构
    struct WorkRecord {
        address contributor;
        uint8 hoursSpent;
        WorkType workType;
        string proof;
        uint256 submissionTime;
        uint256 challengePeriod;
        bool isFinalized;
        bool isChallenged;
    }

    // 工作类型枚举
    enum WorkType {
        Document, // 文档
        Community, // 社区
        Code // 代码
    }

    // 社区成员结构
    struct CommunityMember {
        bool exists; // 是否存在
        bool isActive; // 是否为活跃成员
        bool isFrozen; // 是否被冻结
        uint256 totalHoursValidated; // 总有效工时
    }

    // 状态变量
    mapping(address => CommunityMember) public communityMembers;
    mapping(address => bool) public admins;
    WorkRecord[] public workRecords;

    // 常量
    uint256 public constant CHALLENGE_PERIOD = 14 days;

    // 事件
    event MemberAdded(address indexed member);
    event AdminAdded(address indexed admin);
    event MemberFrozen(address indexed member);
    event WorkRecordSubmitted(
        uint256 indexed recordId,
        address indexed contributor
    );
    event WorkRecordChallenged(
        uint256 indexed recordId,
        address indexed challenger
    );
    event WorkRecordResolved(uint256 indexed recordId, bool successful);
    event WorkRecordAutoFinalized(uint256 indexed recordId);

    // 错误
    error NotOwner();
    error NotAdmin();
    error NotActiveMember();
    error InvalidWorkRecord();
    error ChallengePeriodNotExpired();
    error AlreadyChallenged();
    error CannotChallengeSelfRecord();
    error AdminAlreadyExists();
    error InvalidAddress();

    // 管理员修饰符
    modifier onlyAdmins() {
        if (!admins[msg.sender]) revert NotAdmin();
        _;
    }

    // 活跃成员修饰符
    modifier onlyActiveMember() {
        if (
            !communityMembers[msg.sender].isActive ||
            communityMembers[msg.sender].isFrozen
        ) revert NotActiveMember();
        _;
    }

    // 社区成员数量
    uint256 public communityMembersCount;

    // 合约所有者
    address public owner;

    // 所有者修饰符
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwner();
        }
        _;
    }

    // 构造函数
    constructor() {
        owner = msg.sender;

        // 直接设置管理员和社区成员
        admins[msg.sender] = true;
        communityMembers[msg.sender] = CommunityMember({
            exists: true,
            isActive: true,
            isFrozen: false,
            totalHoursValidated: 0
        });
        communityMembersCount++;
        emit AdminAdded(msg.sender);
        emit MemberAdded(msg.sender);
    }

    // 添加管理员
    function addAdmin(address _admin) external onlyOwner {
        // 检查管理员地址是否有效
        if (_admin == address(0)) {
            revert InvalidAddress();
        }

        // 检查是否已经是管理员
        if (admins[_admin]) {
            revert AdminAlreadyExists();
        }

        // 添加管理员
        admins[_admin] = true;

        if (!communityMembers[_admin].exists) {
            communityMembers[_admin] = CommunityMember({
                exists: true,
                isActive: true,
                isFrozen: false,
                totalHoursValidated: 0
            });
            communityMembersCount++;
        }

        emit AdminAdded(_admin);
        emit MemberAdded(_admin);
    }

    // 添加社区成员
    function addCommunityMember(address _member) external onlyAdmins {
        require(!communityMembers[_member].exists, "Member already exists");

        communityMembers[_member] = CommunityMember({
            exists: true,
            isActive: true,
            isFrozen: false,
            totalHoursValidated: 0
        });
        communityMembersCount++;
        emit MemberAdded(_member);
    }

    // 冻结社区成员
    function freezeMember(address _member) external onlyAdmins {
        require(communityMembers[_member].isActive, "Member not found");
        communityMembers[_member].isFrozen = true;

        emit MemberFrozen(_member);
    }

    // 提交工作记录
    function submitWorkRecord(
        uint8 _hoursSpent,
        WorkType _workType,
        string memory _proof
    ) external onlyActiveMember returns (uint256) {
        if (_hoursSpent == 0 || _hoursSpent > 10) {
            revert InvalidWorkRecord();
        }

        uint256 recordId = workRecords.length;
        
        WorkRecord memory newRecord = WorkRecord({
            contributor: msg.sender,
            hoursSpent: _hoursSpent,
            workType: _workType,
            proof: _proof,
            submissionTime: block.timestamp,
            challengePeriod: block.timestamp + CHALLENGE_PERIOD,
            isFinalized: false,
            isChallenged: false
        });

        workRecords.push(newRecord);
        emit WorkRecordSubmitted(recordId, msg.sender);
        return recordId;
    }

    // 挑战工作记录
    function challengeWorkRecord(uint256 _recordId) external onlyActiveMember {
        WorkRecord storage record = workRecords[_recordId];

        // 检查是否在挑战期内
        if (block.timestamp > record.challengePeriod) {
            revert ChallengePeriodNotExpired();
        }

        // 检查是否已被挑战
        if (record.isChallenged) {
            revert AlreadyChallenged();
        }

        // 防止自己挑战自己的工作记录
        if (record.contributor == msg.sender) {
            revert CannotChallengeSelfRecord();
        }

        record.isChallenged = true;

        emit WorkRecordChallenged(_recordId, msg.sender);
    }

    // 解决挑战
    function resolveChallenge(
        uint256 _recordId,
        bool _challengeAccepted
    ) external onlyAdmins {
        WorkRecord storage record = workRecords[_recordId];

        // 检查是否已被挑战
        require(record.isChallenged, "Record not challenged");

        if (_challengeAccepted) {
            // 挑战成功，清除原记录的工时
            record.isFinalized = false;
            record.hoursSpent = 0;
        } else {
            // 挑战失败，确认工作记录
            record.isFinalized = true;
            communityMembers[record.contributor].totalHoursValidated += record
                .hoursSpent;
        }

        emit WorkRecordResolved(_recordId, _challengeAccepted);
    }

    // 获取成员总有效工时
    function getMemberTotalHours(
        address _member
    ) external view returns (uint256) {
        return communityMembers[_member].totalHoursValidated;
    }

    // 获取未完成的工作记录
    function getPendingRecords() public view returns (WorkRecord[] memory) {
        uint256 pendingCount = 0;
        for (uint256 i = 0; i < workRecords.length; i++) {
            if (!workRecords[i].isFinalized) {
                pendingCount++;
            }
        }

        WorkRecord[] memory pendingRecords = new WorkRecord[](pendingCount);
        uint256 currentIndex = 0;
        for (uint256 i = 0; i < workRecords.length; i++) {
            if (!workRecords[i].isFinalized) {
                pendingRecords[currentIndex] = workRecords[i];
                currentIndex++;
            }
        }

        return pendingRecords;
    }

    function finalizeRecord(uint256 _recordId) external {
        WorkRecord storage record = workRecords[_recordId];

        // 检查是否超过挑战期且未被挑战
        require(
            block.timestamp > record.challengePeriod,
            "Challenge period not over"
        );
        require(!record.isChallenged, "Record is challenged");
        require(!record.isFinalized, "Record already finalized");

        // 自动确认记录
        record.isFinalized = true;
        communityMembers[record.contributor].totalHoursValidated += record
            .hoursSpent;

        emit WorkRecordAutoFinalized(_recordId);
    }
}

