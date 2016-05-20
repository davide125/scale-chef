# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2

default['scale_sudo'] = {
  'aliases' => {
    'host' => {},
    'user' => {},
    'command' => {},
  },
  'defaults' => [
    '!visiblepw',
    'always_set_home',
    'env_reset',
    'env_keep="COLORS DISPLAY HOSTNAME HISTSIZE INPUTRC KDEDIR LS_COLORS ' +
      'MAIL PS1 PS2 QTDIR USERNAME LANG LC_ADDRESS LC_CTYPE ' +
      'LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES ' +
      'LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE ' +
      'LC_TIME LC_ALL LANGUAGE LINGUAS _XKB_CHARSET XAUTHORITY"',
    'secure_path = /sbin:/bin:/usr/sbin:/usr/bin',
  ],
  'users' => {
    '%sudo' => 'ALL=(ALL) ALL',
  },
}
