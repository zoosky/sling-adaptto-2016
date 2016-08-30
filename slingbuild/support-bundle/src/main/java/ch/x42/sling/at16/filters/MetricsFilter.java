package ch.x42.sling.at16.filters;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;

import org.apache.felix.scr.annotations.Component;
import org.apache.felix.scr.annotations.Properties;
import org.apache.felix.scr.annotations.Property;
import org.apache.felix.scr.annotations.Reference;
import org.apache.felix.scr.annotations.Service;
import org.apache.sling.commons.metrics.MetricsService;
import org.apache.sling.commons.metrics.Timer;

/** Sling Filter that provides useful metrics for our demo */
@Component(immediate=true, metatype=false)
@Service(value=javax.servlet.Filter.class)
@Properties({
    @Property(name="sling.filter.scope", value="request")
})
public class MetricsFilter implements Filter {

    public static final String T_PREFIX = MetricsFilter.class.getName() + ".requests";

    @Reference
    private MetricsService metrics;

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void destroy() {
    }

    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain chain)
        throws IOException, ServletException
    {
        final HttpServletRequest request = (HttpServletRequest)servletRequest;

        final Timer.Context requestTimer = metrics.timer(T_PREFIX).time();
        final Timer.Context methodTimer = metrics.timer(T_PREFIX + "." + request.getMethod()).time();

        try {
            chain.doFilter(servletRequest, servletResponse);
        } finally {
            requestTimer.stop();
            methodTimer.stop();
        }
    }

}
