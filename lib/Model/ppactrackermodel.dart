class ppactrackermodel {
  ppactrackermodel(
      {required this.title, required this.units, required this.period});

  late String title;
  late String units;
  late String period;
}

class reportstudiesmodel {
  reportstudiesmodel(
      {required this.reporttitle,
      required this.reportfilename,
      required this.reportperiod});

  late String reporttitle;
  late String reportfilename;
  late String reportperiod;
  bool isdownloadreport = false;
}

class forecastanalysismodel {
  forecastanalysismodel(
      {required this.reporttitle,
      required this.reportfilename,
      required this.reportperiod});

  late String reporttitle;
  late String reportfilename;
  late String reportperiod;
  bool isdownloadreport = false;
}

class ppacnewsmodel {
  ppacnewsmodel(
      {required this.id,
      required this.newstitle,
      required this.newsurl,
      required this.newsperiod});

  int id;
  late String newstitle;
  late String newsurl;
  late String newsperiod;
}
