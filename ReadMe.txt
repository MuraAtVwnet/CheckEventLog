�� �@�\
    10�����ƂɃC�x���g���O��ǂ�ŁA�ʒm�Ώۂ̃C�x���g������΃��[�����܂��B

�� �����
    �ȉ����ł̉ғ����т�����܂��B
        Windows Server 2008 R2
        Windows Server 2012
        Windows Server 2012 R2
        Windows Server 2016 TP5

�� �C���X�g�[�����@
    �K���ȃt�H���_�[�ɑS�Ẵt�@�C�����R�s�[

    ConfigCommon.ps1 �́u### �K���ݒ肷�鍀�� ###�v��ݒ�

    ConfigNode.ps1 �́u### �K���ݒ肷�鍀�� ###�v��ݒ�
        �u�`�F�b�N����A�v���P�[�V�����ƃT�[�r�X���O�v���w�肷��ƁA�A�v���P�[�V�������O���`�F�b�N���܂��B
        �K�v�ɉ����ăT�[�o�[�p�̃��O���Z�b�g���Ă��������B(Hyper-V/AD DS/DNS�̏ꍇ�́A�����ʐݒ���ݒ肷��� OK

    �Ǘ������� Install.ps1 �����s

�� ����m�F
    TestEvent.ps1 ���Ǘ������Ŏ��s����ƁA���̃`�F�b�N���Ƀ��[�������M�����

�� �A���C���X�g�[�����@
    �Ǘ������� Uninstall.ps1 �����s
    �S�Ẵt�@�C�����폜

�� �Ď�����
    CheckEventLog.ps1
        �Ď��X�N���v�g�{��

    �C�x���g�ʓ��쐧��� ConfigEvent.ps1 �Őݒ肷��

    �G���[
        ��{�S���ʒm
        �X���[�C�x���g�w��

    �x��
        ��{�X���[
        �ʒm�C�x���g�w��

    ���
        ��{�X���[
        �ʒm�C�x���g�w��

�� ���O�N���[���i�b�v
    RemoveExecLog.ps1
        �ۑ�����(5��)���߂������s���O(*.log)���폜

�� �W�J�⏕�@�\
    Install.ps1
        �X�P�W���[���o�^

    Uninstall.ps1
        �X�P�W���[���폜

    TestEvent.ps1
        �e�X�g�p�C�x���g���O�L�^

�� �ݒ���
    ���ʐݒ�
        ConfigCommon.ps1
            �S�̋��ʐݒ�

        ConfigEvent.ps1
            �X���[/���o����C�x���g

    �m�[�h�ŗL�ݒ�
            ConfigNode.ps1

�� �t�@�C�� & �f�B���N�g���\��
    �z�u��\
        CheckEventLog.ps1
            �C�x���g���O�Ď��{��
        RemoveExecLog.ps1
            �ۑ����Ԑ؂���s���O�폜
        GetDate.dat
            �O����s����

        Install.ps1
            �C�x���g���O�Ď��o�^
        Uninstall.ps1
            �C�x���g���O�Ď��폜
        TestEvent.ps1
            �e�X�g�p�C�x���g���O�L�^

        ConfigCommon.ps1
            ���ʐݒ�
        ConfigNode.ps1
            �m�[�h�ݒ�
        ConfigEvent.ps1
            �C�x���g�̃X���[/���o�ݒ�

        Log\
            ���s���O

�� ���[���ɋL�ڂ���Ă�����

    �E�^�C�g��
        ConfigNode.ps1 �̐ݒ肪�\������Ă��鍀��
            �y�z           : �v���W�F�N�g��
            ()             :   �T�[�o�[�̖���

        �Ώۂ̏��
            xxxx           : hostname
            xxxx/9999      : �C�x���g�\�[�X/�C�x���gID

    �E�{��
        ConfigNode.ps1 �̐ݒ肪�\������Ă��鍀��
            Project Name   : �v���W�F�N�g��
            Alias          : �T�[�o�[�̕ʖ�
            Server Type    : �T�[�o�[�̖���

        �Ώۂ̏��
            ( 99 ��)       : ���o���������C�x���g��
            Status         : �G���[�̎��
            Host Name      : �z�X�g��
            IPv4 Address   : IPv4 �A�h���X(�����N���[�J���͊܂܂�)
            IPv6 Address   : IPv6 �A�h���X(�����N���[�J���͊܂܂�)
            Manufacturer   : WMI ���瓾�����[�J�[��
            Model          : WMI ���瓾�����f����
            Serial Number  : WMI ���瓾���V���A���ԍ�(Dell ���� Service TAG)
            OS             : OS �ƃT�[�r�X�p�b�N
            Log Name       : ���o�������O��
            Generated Time : �C�x���g�����o���ꂽ����
            Event Source   : �C�x���g�\�[�X��
            Event ID       : �C�x���gID
            Message        : �C�x���g���O���b�Z�[�W
            XML            : �C�x���g���O�� XML ���

�� �C�x���g���O�̌��o����

    ����G���[�C�x���g�����o���Ȃ��悤�ɂ���ꍇ
        �uEvent Source�v �� �uEvent ID�v�� ConfigEvent.ps1 �́u�X���[����G���[�C�x���g�v�ɒǉ����܂��B

    ����̌x���C�x���g�����o����悤�ɂ���
        �uEvent Source�v �� �uEvent ID�v�� ConfigEvent.ps1 �́u�g���b�v����x���C�x���g�v�ɒǉ����܂��B

        �C�x���g�\�[�X�ƃC�x���gID�́A�C�x���g�r���[�A�Łu�ڍׁv�^�u���J���ASystem ��W�J���Ƃ��ɕ\�������A�uProvider�v�ƁuEventID�v�ł��B
            EventLog_001.png

    ����̏��C�x���g�����o����悤�ɂ���
        �x���Ɠ��l�Ɂu�g���b�v������C�x���g�v�ɁuEvent Source�v �� �uEvent ID�v��ǉ����܂��B

    Dell Server �ŉ^�p���Ă����̂ŁADell �� Server Administrator �C�x���g�����o����悤�ɂ��Ă��܂��B(Dell �ȊO�ł����̂܂܉^�p���Ď��Q����)

    �����[�J�[�̊Ǘ��c�[���̃C�x���g�����o����Ώۂɂ���ꍇ�́A�K�X�������Ă��������B

�� �ŐV��
    �ŐV�ňȉ��Ō��J���Ă��܂�

    PowerShell �ŃC�x���g���O�Ď�
    http://www.vwnet.jp/Windows/PowerShell/EventLogMonitoring.htm

�� �X�V����
    2016/08/27  1.00 ���J�p
    2016/08/29  1.01 Install.ps1 / Uninstall.ps1 �����s����s��Ή�
                     XML ���ςȂƂ���ɓ��� Bug �C��
                     (���J�p�C�����̘R��ł��� orz)
    2016/09/03  1.02 RemoveExecLog.ps1 �����s����s��Ή�
