---
layout: page
title: Weekly (tentative) Schedule (For a 3-Credit course)
group: Schedule
---

<table class="table table-striped table-hover table-bordered">
  <tr>
    <th>Week</th>
    <th>Date</th>
    <th>Topics</th>
    <th>Notes</th>
    <th>Assignments</th>
  </tr>
{% for item in site.data.spreadsheets.schedule %}
  <tr>
    <td>{{ item.week }}</td>
    <td>{{ item.date }}</td>
    <td>{% if item.lectureNo != "" %}Lecture {{ item.lectureNo }}. {% endif %}{{ item.topics }}</td>
    <td>{{ item.notes | default: "&nbsp;" }}</td>
    <td>{{ item.due }}</td>
  </tr>
{% endfor %}
</table>

<!-- Schedule updated on {{ site.data.spreadsheets_updated.schedule }} -->
