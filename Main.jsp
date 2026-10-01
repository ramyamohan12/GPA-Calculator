<%@ page import="java.util.*, java.text.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>GPA Calculator</title>
<style>
    body {
        font-family: Arial, sans-serif;
        background-color: #fdf6f0; /* Soft peach background */
        padding: 20px;
    }
    .box {
        background-color: #ffffff;
        padding: 20px;
        margin-bottom: 20px;
        border-radius: 10px;
        box-shadow: 0 0 10px #e0d6d1;
        border: 1px solid #f2e5dc;
    }
    input, select {
        margin: 5px 0;
        padding: 6px 8px;
        border: 1px solid #dcb5ab;
        border-radius: 6px;
        background-color: #fff7f4;
    }
    input[type="submit"] {
        background-color: #ffcabd;
        border: none;
        color: #5a3e36;
        padding: 8px 16px;
        margin-top: 10px;
        cursor: pointer;
        border-radius: 6px;
        font-weight: bold;
    }
    input[type="submit"]:hover {
        background-color: #ffc2b2;
    }
    h1, h2, h3 {
        color: #7a5c4a;
    }
</style>
</head>
<body>
<h1>GPA Calculator</h1>

<%
    String step = request.getParameter("step");

    if (step == null) {
%>
    <form method="post">
        <div class="box">
            <label>How many school years do you want to input?</label><br>
            <input type="number" name="years" min="1" required><br><br>
            <input type="hidden" name="step" value="setupYears">
            <input type="submit" value="Next">
        </div>
    </form>
<%
    } else if (step.equals("setupYears")) {
        int years = Integer.parseInt(request.getParameter("years"));
%>
    <form method="post">
        <input type="hidden" name="step" value="setupClasses">
        <input type="hidden" name="years" value="<%= years %>">
<%
        for (int y = 0; y < years; y++) {
%>
        <div class="box">
            <h3>Year <%= y+1 %> Info</h3>
            <label>Academic system:</label>
            <select name="system_<%=y%>">
                <option value="semester">Semester</option>
                <option value="trimester">Trimester</option>
                <option value="quarter">Quarter</option>
                <option value="full">Full Year</option>
            </select><br>
            <label>How many classes?</label>
            <input type="number" name="classes_<%=y%>" min="1" required><br>
        </div>
<%
        }
%>
        <input type="submit" value="Next">
    </form>
<%
    } else if (step.equals("setupClasses")) {
        int years = Integer.parseInt(request.getParameter("years"));
%>
    <form method="post">
        <input type="hidden" name="step" value="calculate">
        <input type="hidden" name="years" value="<%= years %>">
<%
        for (int y = 0; y < years; y++) {
            int classes = Integer.parseInt(request.getParameter("classes_" + y));
            String system = request.getParameter("system_" + y);
            int termCount = 1;
            if ("semester".equals(system)) termCount = 2;
            else if ("trimester".equals(system)) termCount = 3;
            else if ("quarter".equals(system)) termCount = 4;
%>
        <input type="hidden" name="classes_<%=y%>" value="<%= classes %>">
        <input type="hidden" name="system_<%=y%>" value="<%= system %>">
        <div class="box">
            <h3>Year <%= y+1 %> (<%= system.substring(0,1).toUpperCase()+system.substring(1) %>)</h3>
<%
            for (int c = 0; c < classes; c++) {
%>
                <fieldset>
                    <legend>Class <%= c+1 %></legend>
                    Name: <input type="text" name="name_<%=y%>_<%=c%>" required><br>
                    Credits (total for the year): <input type="number" step="0.1" name="credit_<%=y%>_<%=c%>" required><br>
<%
                for (int t = 0; t < termCount; t++) {
                    String termLabel = "";
                    switch (termCount) {
                        case 2: termLabel = "Semester " + (t+1); break;
                        case 3: termLabel = "Trimester " + (t+1); break;
                        case 4: termLabel = "Quarter " + (t+1); break;
                        default: termLabel = "Final Grade"; break;
                    }
%>
                    <%= termLabel %> Grade: <input type="text" name="grade_<%=y%>_<%=c%>_<%=t%>" required><br>
<%
                }
%>
                    AP/IB?
                    <select name="adv_<%=y%>_<%=c%>">
                        <option value="n">No</option>
                        <option value="y">Yes</option>
                    </select>
                </fieldset>
<%
            }
%>
        </div>
<%
        }
%>
        <input type="submit" value="Calculate GPA">
    </form>
<%
    } else if (step.equals("calculate")) {
        int years = Integer.parseInt(request.getParameter("years"));
        DecimalFormat df = new DecimalFormat("#.##");

        double totalQualityPoints = 0.0;
        double totalCredits = 0.0;
%>
    <h2>GPA Results</h2>
<%
        for (int y = 0; y < years; y++) {
            int classes = Integer.parseInt(request.getParameter("classes_" + y));
            String system = request.getParameter("system_" + y);
            int termCount = 1;
            if ("semester".equals(system)) termCount = 2;
            else if ("trimester".equals(system)) termCount = 3;
            else if ("quarter".equals(system)) termCount = 4;
%>
        <div class="box">
            <h3>Year <%= y+1 %> (<%= system.substring(0,1).toUpperCase()+system.substring(1) %>)</h3>
            <ul>
<%
            for (int c = 0; c < classes; c++) {
                String name = request.getParameter("name_" + y + "_" + c);
                double credit = Double.parseDouble(request.getParameter("credit_" + y + "_" + c));
                boolean adv = "y".equalsIgnoreCase(request.getParameter("adv_" + y + "_" + c));

                double classQualityPoints = 0.0;

                double creditPerTerm = credit / termCount;

                for (int t = 0; t < termCount; t++) {
                    String grade = request.getParameter("grade_" + y + "_" + c + "_" + t);
                    double gpaPoint = 0.0;
                    if ("A".equalsIgnoreCase(grade) || "A+".equalsIgnoreCase(grade)) gpaPoint = adv ? 5.0 : 4.0;
                    else if ("A-".equalsIgnoreCase(grade)) gpaPoint = adv ? 4.7 : 3.7;
                    else if ("B+".equalsIgnoreCase(grade)) gpaPoint = adv ? 4.3 : 3.3;
                    else if ("B".equalsIgnoreCase(grade)) gpaPoint = adv ? 4.0 : 3.0;
                    else if ("B-".equalsIgnoreCase(grade)) gpaPoint = adv ? 3.7 : 2.7;
                    else if ("C+".equalsIgnoreCase(grade)) gpaPoint = adv ? 3.3 : 2.3;
                    else if ("C".equalsIgnoreCase(grade)) gpaPoint = adv ? 3.0 : 2.0;
                    else if ("C-".equalsIgnoreCase(grade)) gpaPoint = adv ? 2.7 : 1.7;
                    else if ("D+".equalsIgnoreCase(grade)) gpaPoint = adv ? 2.3 : 1.3;
                    else if ("D".equalsIgnoreCase(grade)) gpaPoint = adv ? 2.0 : 1.0;
                    else if ("D-".equalsIgnoreCase(grade)) gpaPoint = adv ? 1.7 : 0.7;
                    else if ("F".equalsIgnoreCase(grade)) gpaPoint = adv ? 1.0 : 0.0;

                    classQualityPoints += gpaPoint * creditPerTerm;
                }

                totalQualityPoints += classQualityPoints;
                totalCredits += credit; 
%>
                <li><%= name %> – Credits: <%= credit %>, Weighted: <%= adv ? "Yes" : "No" %></li>
<%
            }
%>
            </ul>
        </div>
<%
        }
        double gpa = totalQualityPoints / totalCredits;
%>
    <h2>Cumulative GPA: <%= df.format(gpa) %></h2>
    <form method="post">
        <input type="submit" value="Restart">
    </form>
<%
    }
%>
</body>
</html>
