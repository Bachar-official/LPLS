enum Velocity {
  off(0),

  darkGrey(1),
  lightGrey(2),
  white(3),

  darkRed(7),
  red(6),
  lightRed(5),

  darkOrange(11),
  orange(10),
  lightOrange(9),

  darkYellow(15),
  yellow(14),
  lightYellow(13),

  darkGreemWarm(19),
  greemWarm(18),
  lightGreemWarm(17),

  darkGreen(23),
  green(22),
  lightGreen(21),

  darkDyan(31),
  dyan(30),
  lightDyan(29),

  darkMagenta(39),
  magenta(38),
  lightMagenta(37),

  darkBlue(47),
  blue(46),
  lightBlue(45);

  final int value;
  const Velocity(this.value);
}
