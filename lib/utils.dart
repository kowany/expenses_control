int daysInMonth( int month ) {

  var now = DateTime.now();

  var lastDayDateTime = ( month < 11 ) ? 
      new DateTime( now.year, month + 1, 0 ) :
      new DateTime( now.year + 1 , 1, 0 );

  return lastDayDateTime.day;
  
}