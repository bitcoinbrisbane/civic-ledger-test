/**
@title Membership contract which allows owner to add / revoke membership
@author Naveen Palaniswamy
@copyright Naveen Palaniswamy
*/

pragma solidity ^0.4.19;

import "./Owned.sol";


contract Membership is Owned {

    struct Member {
        address memberAddrs;
        string firstName;
        string lastName;
        string companyURL;
        string linkedInURL;
        string twitterURL;
    }

    uint32[] private applicationIds;
    /// Mapping application id to Applicant details
    mapping(uint32 => Member) private pendingApplicants;

    uint32[] private memberIds;
    mapping(uint32 => Member) private members;

    event LogMembershipApplied(uint32 applicationId, address indexed owner, address indexed memberAddrs);
    event LogMembershipAdded(uint32 applicationId, uint32 memberId, address indexed owner, address indexed memberAddrs);
    event LogMembershipRevoked(uint32 memberId, address indexed owner, address indexed memberAddrs);

    /**
    @notice This function is invoked to apply for a membership and requires ether to be sent
            as part of the transaction.
    @param _firstName First name of the applicant
    @param _lastName Last name of the applicant
    @param _companyURL Company URL of the applicant
    @param _linkedInURL Company URL of the applicant
    @param _twitterURL Twitter URL of the applicant
    */
    function applyForMembership (
        string _firstName,
        string _lastName,
        string _companyURL,
        string _linkedInURL,
        string _twitterURL
    )
        public
        payable
    {
        /// Validate that ether is sent in txn
        require(msg.value > 0);

        /// Validate input parameters
        require(
            (msg.sender != address(0)) &&
            !isEmptyString(_firstName) &&
            !isEmptyString(_lastName) &&
            !isEmptyString(_companyURL) &&
            !isEmptyString(_linkedInURL) &&
            !isEmptyString(_twitterURL)
        );

        Member memory pendingMember = Member({
            memberAddrs : msg.sender,
            firstName : _firstName,
            lastName : _lastName,
            companyURL : _companyURL,
            linkedInURL : _linkedInURL,
            twitterURL : _twitterURL
        });

        uint32 applicationsCount = uint32(applicationIds.length);
        uint32 applicationId = applicationsCount + 1;

        LogMembershipApplied(applicationId, owner, msg.sender);

        pendingApplicants[applicationId] = pendingMember;

        applicationIds.push(applicationId);
    }

    /**
    @notice This function confirms a pending applicant as a member
            Requires the contract owner to be the executor
    @param _applicationId The application identifier
    */
    function addMembership(uint32 _applicationId)
        public
        onlyOwner
    {
        /// verify that the incoming application is pending
        require(!isEmptyString(pendingApplicants[_applicationId].firstName));
        uint memberIdU256 = memberIds.length + 1;
        assert(memberIdU256 > memberIds.length);
        uint32 memberId = uint32(memberIdU256);

        Member memory pendingApplicant = pendingApplicants[_applicationId];

        Member memory member = Member({
            memberAddrs : pendingApplicant.memberAddrs,
            firstName : pendingApplicant.firstName,
            lastName : pendingApplicant.lastName,
            companyURL : pendingApplicant.companyURL,
            linkedInURL : pendingApplicant.linkedInURL,
            twitterURL : pendingApplicant.twitterURL
        });

        LogMembershipAdded(_applicationId, memberId, owner, member.memberAddrs);

        members[memberId] = member;
        memberIds.push(memberId);

        delete pendingApplicants[_applicationId];
    }

    /**
    @notice This function revokes the membership of an existing member
            Requires the contract owner to be the executor
    @param _memberId Member identifier
    */
    function revokeMembership(uint32 _memberId) public onlyOwner {
        /// verify that the incoming member id is valid
        require(!isEmptyString(members[_memberId].firstName));
        Member memory member = members[_memberId];

        LogMembershipRevoked(_memberId, owner, member.memberAddrs);

        delete members[_memberId];
        delete memberIds[_memberId - 1];
    }

    /**
    @notice This function returns the details of a pending applicant
    @param _applicationId Application identifier
    @return {
      "_memberAddrs" : "Address of the applicant",
      "_firstName" : "First name of the applicant",
      "_lastName" : "Last name of the applicant",
      "_companyURL" : "Company URL of the applicant",
      "_linkedInURL" : "LinkedIn URL of the applicant",
      "_twitterURL" : "Twitter URL of the applicant"
    }
    */
    function getPendingApplicationDetails(uint32 _applicationId)
        public
        view
        returns(
            address _memberAddrs,
            string  _firstName,
            string  _lastName,
            string  _companyURL,
            string  _linkedInURL,
            string  _twitterURL
        )
    {
        /// verify that the incoming application is pending
        require(!isEmptyString(pendingApplicants[_applicationId].firstName));

        Member memory pendingApplication = pendingApplicants[_applicationId];
        _memberAddrs = pendingApplication.memberAddrs;
        _firstName = pendingApplication.firstName;
        _lastName = pendingApplication.lastName;
        _companyURL = pendingApplication.companyURL;
        _linkedInURL = pendingApplication.linkedInURL;
        _twitterURL = pendingApplication.twitterURL;
    }

    /**
    @notice This function returns the details of a member
    @param _memberId Member identifier
    @return {
      "_memberAddrs" : "Address of the applicant",
      "_firstName" : "First name of the applicant",
      "_lastName" : "Last name of the applicant",
      "_companyURL" : "Company URL of the applicant",
      "_linkedInURL" : "LinkedIn URL of the applicant",
      "_twitterURL" : "Twitter URL of the applicant"
    }
    */
    function getMemberDetails(uint32 _memberId)
        public
        view
        returns(
            address _memberAddrs,
            string  _firstName,
            string  _lastName,
            string  _companyURL,
            string  _linkedInURL,
            string  _twitterURL
        )
    {
        /// verify that the incoming member id is valid
        require(!isEmptyString(members[_memberId].firstName));

        Member memory member = members[_memberId];
        _memberAddrs = member.memberAddrs;
        _firstName = member.firstName;
        _lastName = member.lastName;
        _companyURL = member.companyURL;
        _linkedInURL = member.linkedInURL;
        _twitterURL = member.twitterURL;
    }

    /**
    @notice This function transfers balance fund to provided _recipient address
            Requires the contract owner to be the executor
    @param _recipient Recipient address
    */
    function transferFunds(address _recipient) public onlyOwner {
        _recipient.transfer(this.balance);
    }

    /**
    @notice This function will destroy the contract and transfer balance to contract owner
            Requires the contract owner to be the executor
    */
    function destroy() public onlyOwner {
        selfdestruct(owner);
    }

    /**
    @notice This function checks if the incoming string is empty
    @param _strVal String value
    @return _isEmpty true / false
    */
    function isEmptyString(string _strVal)
        internal
        pure
        returns (bool _isEmpty)
    {
        _isEmpty = true;
        bytes memory string2bytes = bytes(_strVal);
        if (string2bytes.length > 0) {
            _isEmpty = false;
        }
    }

}
