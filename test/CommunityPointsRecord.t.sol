// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/points-record.sol";

contract CommunityPointsRecordTest is Test {
    CommunityPointsRecord public pointsRecord;
    address public owner;
    address public admin;
    address public member1;
    address public member2;

    // 设置测试环境
    function setUp() public {
        // 部署合约
        owner = address(this);
        pointsRecord = new CommunityPointsRecord();
        
        // 设置测试账户
        admin = makeAddr("admin");
        member1 = makeAddr("member1");
        member2 = makeAddr("member2");

        // 添加管理员和成员
        pointsRecord.addAdmin(admin);
        vm.prank(admin);
        pointsRecord.addCommunityMember(member1);
    }

    // 测试初始化状态
    function test_InitialState() public {
        assertTrue(pointsRecord.admins(owner));
        assertTrue(pointsRecord.admins(admin));
        assertEq(pointsRecord.owner(), owner);
    }

    // 测试添加社区成员
    function test_AddCommunityMember() public {
        vm.prank(admin);
        pointsRecord.addCommunityMember(member2);
        
        (bool exists, bool isActive, bool isFrozen, ) = pointsRecord.communityMembers(member2);
        assertTrue(exists);
        assertTrue(isActive);
        assertFalse(isFrozen);
    }

    // 测试提交工作记录
    function test_SubmitWorkRecord() public {
        vm.prank(member1);
        uint256 recordId = pointsRecord.submitWorkRecord(
            8,
            CommunityPointsRecord.WorkType.Code,
            "https://github.com/commit/123"
        );

        // 验证记录
        (
            address contributor,
            uint8 hoursSpent,
            CommunityPointsRecord.WorkType workType,
            ,  // proof
            ,  // submissionTime
            ,  // challengePeriod
            ,  // isFinalized
            // isChallenged
        ) = pointsRecord.workRecords(recordId);

        assertEq(contributor, member1);
        assertEq(hoursSpent, 8);
        assertEq(uint(workType), uint(CommunityPointsRecord.WorkType.Code));
    }

    // 测试挑战工作记录
    function test_ChallengeWorkRecord() public {
        // 首先提交一个工作记录
        vm.prank(member1);
        uint256 recordId = pointsRecord.submitWorkRecord(
            8,
            CommunityPointsRecord.WorkType.Code,
            "https://github.com/commit/123"
        );

        // member2 挑战该记录
        vm.prank(admin);
        pointsRecord.addCommunityMember(member2);
        
        vm.prank(member2);
        pointsRecord.challengeWorkRecord(recordId);

        // 验证记录被挑战
        (,,,,,, bool isFinalized, bool isChallenged) = pointsRecord.workRecords(recordId);
        assertTrue(isChallenged);
        assertFalse(isFinalized);
    }

    // 测试解决挑战
    function test_ResolveChallenge() public {
        // 提交记录
        vm.prank(member1);
        uint256 recordId = pointsRecord.submitWorkRecord(
            8,
            CommunityPointsRecord.WorkType.Code,
            "https://github.com/commit/123"
        );

        // 发起挑战
        vm.prank(admin);
        pointsRecord.addCommunityMember(member2);
        
        vm.prank(member2);
        pointsRecord.challengeWorkRecord(recordId);

        // 解决挑战
        vm.prank(admin);
        pointsRecord.resolveChallenge(recordId, false);

        // 验证结果
        (,,,,,,bool isFinalized, bool isChallenged) = pointsRecord.workRecords(recordId);
        assertTrue(isFinalized);
        assertEq(pointsRecord.getMemberTotalHours(member1), 8);
    }

    // 测试自动确认记录
    function test_FinalizeRecord() public {
        // 提交记录
        vm.prank(member1);
        uint256 recordId = pointsRecord.submitWorkRecord(
            8,
            CommunityPointsRecord.WorkType.Code,
            "https://github.com/commit/123"
        );

        // 等待挑战期结束
        vm.warp(block.timestamp + 15 days);

        // 确认记录
        pointsRecord.finalizeRecord(recordId);

        // 验证结果
        (,,,,,,bool isFinalized, bool isChallenged) = pointsRecord.workRecords(recordId);
        assertTrue(isFinalized);
        assertEq(pointsRecord.getMemberTotalHours(member1), 8);
    }

    // 测试错误情况
    function testFail_InvalidHours() public {
        vm.prank(member1);
        pointsRecord.submitWorkRecord(
            11, // 超过最大工时限制
            CommunityPointsRecord.WorkType.Code,
            "https://github.com/commit/123"
        );
    }

    function testFail_SelfChallenge() public {
        // 提交记录
        vm.prank(member1);
        uint256 recordId = pointsRecord.submitWorkRecord(
            8,
            CommunityPointsRecord.WorkType.Code,
            "https://github.com/commit/123"
        );

        // 尝试自己挑战自己的记录
        vm.prank(member1);
        pointsRecord.challengeWorkRecord(recordId);
    }
} 